#!/usr/bin/env zit
const std = @import("std");

const Args = struct {
    repo: []const u8 = "",
    tap: []const u8 = "",
    tag: []const u8 = "",
    formula: []const u8 = "",
    workdir: []const u8 = ".",
    tap_dir: []const u8 = "tap-repo",
    dry: bool = false,
    no_push: bool = false,
};

const BuildTarget = struct { triple: []const u8, suffix: []const u8 };

pub fn main() !void {
    const a = std.heap.page_allocator;
    const args = try parseArgs(a);

    if (args.repo.len == 0 or args.tap.len == 0 or args.tag.len == 0) {
        help();
        return error.InvalidArguments;
    }

    const repo = try splitPair(args.repo);
    const tap = try splitPair(args.tap);
    const formula_name = if (args.formula.len > 0) args.formula else repo.name;
    const bin_name = formula_name;

    const source_root = try std.fmt.allocPrint(a, "{s}/source-repos", .{args.workdir});
    defer a.free(source_root);
    try std.fs.cwd().makePath(source_root);

    const src = try std.fmt.allocPrint(a, "{s}/{s}", .{ source_root, repo.name });
    defer a.free(src);

    const tap_dir = if (std.mem.startsWith(u8, args.tap_dir, "/"))
        args.tap_dir
    else
        try std.fmt.allocPrint(a, "{s}/{s}", .{ args.workdir, args.tap_dir });
    defer if (!std.mem.startsWith(u8, args.tap_dir, "/")) a.free(tap_dir);

    try std.fs.cwd().makePath(args.workdir);
    try ensureTapRepo(a, tap_dir, tap.owner, tap.name);

    std.debug.print("==> source: {s}\n", .{src});
    try ensureSourceRepo(a, src, repo.owner, repo.name);

    // Ensure tag exists
    const tag_ref = try std.fmt.allocPrint(a, "refs/tags/{s}", .{args.tag});
    defer a.free(tag_ref);
    _ = cap(a, &.{ "git", "-C", src, "rev-parse", "--verify", tag_ref }) catch {
        std.debug.print("error: missing tag {s} in {s}\n", .{ args.tag, src });
        return error.MissingTag;
    };

    const work = try std.fmt.allocPrint(a, "/tmp/{s}-release-{s}", .{ repo.name, args.tag });
    defer a.free(work);
    try std.fs.cwd().makePath(work);

    const targets = [_]BuildTarget{
        .{ .triple = "x86_64-macos", .suffix = "darwin-amd64" },
        .{ .triple = "aarch64-macos", .suffix = "darwin-arm64" },
        .{ .triple = "x86_64-linux-gnu", .suffix = "linux-amd64" },
        .{ .triple = "aarch64-linux-gnu", .suffix = "linux-arm64" },
    };

    var shas = std.StringHashMap([]const u8).init(a);
    defer shas.deinit();

    for (targets) |t| {
        const d = try std.fmt.allocPrint(a, "{s}/{s}", .{ work, t.suffix });
        defer a.free(d);
        try std.fs.cwd().makePath(d);

        const out_bin = try std.fmt.allocPrint(a, "{s}/{s}", .{ d, bin_name });
        defer a.free(out_bin);

        std.debug.print("==> build {s}\n", .{t.suffix});
        const build_zig = try std.fmt.allocPrint(a, "{s}/build.zig", .{src});
        defer a.free(build_zig);
        if (exists(build_zig)) {
            const target_arg = try std.fmt.allocPrint(a, "-Dtarget={s}", .{t.triple});
            defer a.free(target_arg);
            try runIn(a, &.{ "zig", "build", "-Doptimize=ReleaseFast", target_arg }, src);
            const built_bin = try std.fmt.allocPrint(a, "{s}/zig-out/bin/{s}", .{ src, bin_name });
            defer a.free(built_bin);
            try run(a, &.{ "cp", built_bin, out_bin });
        } else {
            const src_file = try std.fmt.allocPrint(a, "{s}.zig", .{repo.name});
            defer a.free(src_file);
            const emit_arg = try std.fmt.allocPrint(a, "-femit-bin={s}", .{out_bin});
            defer a.free(emit_arg);
            try runIn(a, &.{ "zig", "build-exe", src_file, "-ODebug", "-fstrip", "-target", t.triple, emit_arg }, src);
        }

        const tgz = try std.fmt.allocPrint(a, "{s}/{s}-{s}.tar.gz", .{ work, repo.name, t.suffix });
        defer a.free(tgz);
        try run(a, &.{ "tar", "-C", d, "-czf", tgz, bin_name });

        const sr = try cap(a, &.{ "shasum", "-a", "256", tgz });
        defer a.free(sr);
        try shas.put(try a.dupe(u8, t.suffix), try a.dupe(u8, tok(trim(sr))));
    }

    // checksums.txt
    const checks = try std.fmt.allocPrint(a, "{s}/checksums.txt", .{work});
    defer a.free(checks);
    const checks_data = try std.fmt.allocPrint(a,
        "{s}  {s}-darwin-amd64.tar.gz\n{s}  {s}-darwin-arm64.tar.gz\n{s}  {s}-linux-amd64.tar.gz\n{s}  {s}-linux-arm64.tar.gz\n",
        .{ shas.get("darwin-amd64").?, repo.name, shas.get("darwin-arm64").?, repo.name, shas.get("linux-amd64").?, repo.name, shas.get("linux-arm64").?, repo.name },
    );
    defer a.free(checks_data);
    try std.fs.cwd().writeFile(.{ .sub_path = checks, .data = checks_data });

    if (!args.dry) {
        const token = std.posix.getenv("GITHUB_TOKEN") orelse std.posix.getenv("GH_TOKEN") orelse {
            std.debug.print("error: GITHUB_TOKEN or GH_TOKEN is required\n", .{});
            return error.MissingToken;
        };

        const rel = try ensureRelease(a, token, repo.owner, repo.name, args.tag);
        std.debug.print("==> release: {s}\n", .{rel.html_url});

        const base_upload = trimUploadUrl(rel.upload_url);
        const upload_names = [_][]const u8{ "darwin-amd64", "darwin-arm64", "linux-amd64", "linux-arm64" };
        for (upload_names) |suf| {
            const file = try std.fmt.allocPrint(a, "{s}/{s}-{s}.tar.gz", .{ work, repo.name, suf });
            defer a.free(file);
            const asset = try std.fmt.allocPrint(a, "{s}-{s}.tar.gz", .{ repo.name, suf });
            defer a.free(asset);
            try deleteAssetIfExists(a, token, repo.owner, repo.name, rel.assets, asset);
            try uploadAsset(a, token, base_upload, asset, file, "application/gzip");
        }
        try deleteAssetIfExists(a, token, repo.owner, repo.name, rel.assets, "checksums.txt");
        try uploadAsset(a, token, base_upload, "checksums.txt", checks, "text/plain");
    } else {
        std.debug.print("==> dry-run: skip release upload\n", .{});
    }

    // write formula in tap repo
    const formula = try std.fmt.allocPrint(a, "{s}/Formula/{s}.rb", .{ tap_dir, formula_name });
    defer a.free(formula);
    try std.fs.cwd().makePath(try std.fmt.allocPrint(a, "{s}/Formula", .{tap_dir}));

    const version = if (std.mem.startsWith(u8, args.tag, "v")) args.tag[1..] else args.tag;
    const content = try std.fmt.allocPrint(a,
        \\class {s} < Formula
        \\  desc "CLI tool {s}"
        \\  homepage "https://github.com/{s}/{s}"
        \\  version "{s}"
        \\  license "MIT"
        \\
        \\  on_macos do
        \\    if Hardware::CPU.arm?
        \\      url "https://github.com/{s}/{s}/releases/download/{s}/{s}-darwin-arm64.tar.gz"
        \\      sha256 "{s}"
        \\    else
        \\      url "https://github.com/{s}/{s}/releases/download/{s}/{s}-darwin-amd64.tar.gz"
        \\      sha256 "{s}"
        \\    end
        \\  end
        \\
        \\  on_linux do
        \\    if Hardware::CPU.arm?
        \\      url "https://github.com/{s}/{s}/releases/download/{s}/{s}-linux-arm64.tar.gz"
        \\      sha256 "{s}"
        \\    else
        \\      url "https://github.com/{s}/{s}/releases/download/{s}/{s}-linux-amd64.tar.gz"
        \\      sha256 "{s}"
        \\    end
        \\  end
        \\
        \\  def install
        \\    bin.install "{s}"
        \\  end
        \\
        \\  test do
        \\    system "#{{bin}}/{s}", "--clean"
        \\  end
        \\end
        \\
    , .{
        try className(a, formula_name), repo.name, repo.owner, repo.name, version,
        repo.owner, repo.name, args.tag, repo.name, shas.get("darwin-arm64").?,
        repo.owner, repo.name, args.tag, repo.name, shas.get("darwin-amd64").?,
        repo.owner, repo.name, args.tag, repo.name, shas.get("linux-arm64").?,
        repo.owner, repo.name, args.tag, repo.name, shas.get("linux-amd64").?,
        bin_name, bin_name,
    });
    defer a.free(content);
    try std.fs.cwd().writeFile(.{ .sub_path = formula, .data = content });

    if (!args.dry) {
        try run(a, &.{ "git", "-C", tap_dir, "add", "Formula" });
        const msg = try std.fmt.allocPrint(a, "chore(formula): release {s} {s}", .{ repo.name, args.tag });
        defer a.free(msg);
        run(a, &.{ "git", "-C", tap_dir, "commit", "-m", msg }) catch {};
        if (!args.no_push) try pushMaybeAuth(a, tap_dir);
    } else {
        std.debug.print("==> dry-run: skip tap commit/push\n", .{});
    }

    std.debug.print("done: {s} {s}\n", .{ args.repo, args.tag });
    std.debug.print("tap install: brew install {s}/{s}/{s}\n", .{ tap.owner, tap.nameNoPrefix(), formula_name });
}

const Pair = struct {
    owner: []const u8,
    name: []const u8,
    fn nameNoPrefix(self: Pair) []const u8 {
        return if (std.mem.startsWith(u8, self.name, "homebrew-")) self.name[9..] else self.name;
    }
};

fn splitPair(s: []const u8) !Pair {
    const i = std.mem.indexOfScalar(u8, s, '/') orelse return error.InvalidArguments;
    return .{ .owner = s[0..i], .name = s[i + 1 ..] };
}

const ReleaseAsset = struct { id: i64, name: []const u8 };
const ReleaseInfo = struct { upload_url: []const u8, html_url: []const u8, assets: []ReleaseAsset };

fn ensureRelease(a: std.mem.Allocator, token: []const u8, owner: []const u8, repo: []const u8, tag: []const u8) !ReleaseInfo {
    const get_url = try std.fmt.allocPrint(a, "https://api.github.com/repos/{s}/{s}/releases/tags/{s}", .{ owner, repo, tag });
    defer a.free(get_url);

    var r = try api(a, token, "GET", get_url, null, null, null);
    if (r.status == 404) {
        const create_url = try std.fmt.allocPrint(a, "https://api.github.com/repos/{s}/{s}/releases", .{ owner, repo });
        defer a.free(create_url);
        const body = try std.fmt.allocPrint(a, "{{\"tag_name\":\"{s}\",\"target_commitish\":\"main\",\"name\":\"{s}\",\"draft\":false,\"prerelease\":false}}", .{ tag, tag });
        defer a.free(body);
        r = try api(a, token, "POST", create_url, body, null, null);
    }
    if (r.status < 200 or r.status >= 300) {
        std.debug.print("github api failed ({d}): {s}\n", .{ r.status, r.body });
        return error.GitHubApiFailed;
    }

    var parsed = try std.json.parseFromSlice(std.json.Value, a, r.body, .{});
    defer parsed.deinit();
    return try releaseFromJson(a, parsed.value);
}

fn releaseFromJson(a: std.mem.Allocator, v: std.json.Value) !ReleaseInfo {
    const o = v.object;
    const upload = o.get("upload_url") orelse return error.InvalidResponse;
    const html = o.get("html_url") orelse return error.InvalidResponse;
    const assets_v = o.get("assets") orelse return error.InvalidResponse;

    const arr = assets_v.array;
    var assets = try std.ArrayList(ReleaseAsset).initCapacity(a, arr.items.len);
    for (arr.items) |it| {
        const io = it.object;
        const idv = io.get("id") orelse continue;
        const nv = io.get("name") orelse continue;
        try assets.append(a, .{ .id = idv.integer, .name = try a.dupe(u8, nv.string) });
    }

    return .{ .upload_url = try a.dupe(u8, upload.string), .html_url = try a.dupe(u8, html.string), .assets = try assets.toOwnedSlice(a) };
}

fn trimUploadUrl(s: []const u8) []const u8 {
    return s[0 .. (std.mem.indexOfScalar(u8, s, '{') orelse s.len)];
}

fn deleteAssetIfExists(a: std.mem.Allocator, token: []const u8, owner: []const u8, repo: []const u8, assets: []const ReleaseAsset, name: []const u8) !void {
    for (assets) |as| {
        if (!std.mem.eql(u8, as.name, name)) continue;
        const u = try std.fmt.allocPrint(a, "https://api.github.com/repos/{s}/{s}/releases/assets/{d}", .{ owner, repo, as.id });
        defer a.free(u);
        _ = try api(a, token, "DELETE", u, null, null, null);
    }
}

fn uploadAsset(a: std.mem.Allocator, token: []const u8, base: []const u8, name: []const u8, file: []const u8, ctype: []const u8) !void {
    const u = try std.fmt.allocPrint(a, "{s}?name={s}", .{ base, name });
    defer a.free(u);
    const data_arg = try std.fmt.allocPrint(a, "@{s}", .{file});
    defer a.free(data_arg);
    const r = try api(a, token, "POST", u, null, ctype, data_arg);
    if (r.status < 200 or r.status >= 300) {
        std.debug.print("upload failed {s} ({d}): {s}\n", .{ name, r.status, r.body });
        return error.UploadFailed;
    }
    std.debug.print("==> uploaded {s}\n", .{name});
}

const ApiResp = struct { status: u16, body: []u8 };
fn api(a: std.mem.Allocator, token: []const u8, method: []const u8, url: []const u8, json_body: ?[]const u8, content_type: ?[]const u8, data_binary: ?[]const u8) !ApiResp {
    var args = try std.ArrayList([]const u8).initCapacity(a, 24);
    defer args.deinit(a);
    try args.appendSlice(a, &.{ "curl", "-sS", "-X", method, "-H" });
    const auth = try std.fmt.allocPrint(a, "Authorization: token {s}", .{token});
    defer a.free(auth);
    try args.append(a, auth);
    try args.appendSlice(a, &.{ "-H", "Accept: application/vnd.github+json" });
    if (content_type) |ct| {
        try args.appendSlice(a, &.{ "-H", try std.fmt.allocPrint(a, "Content-Type: {s}", .{ct}) });
    }
    if (json_body) |b| {
        try args.appendSlice(a, &.{ "-d", b });
    }
    if (data_binary) |d| {
        try args.appendSlice(a, &.{ "--data-binary", d });
    }
    try args.appendSlice(a, &.{ "-w", "\n%{http_code}", url });

    const out = try cap(a, args.items);
    const pos = std.mem.lastIndexOfScalar(u8, out, '\n') orelse return error.InvalidResponse;
    const code = std.fmt.parseInt(u16, trim(out[pos + 1 ..]), 10) catch return error.InvalidResponse;
    return .{ .status = code, .body = out[0..pos] };
}

fn ensureRepo(a: std.mem.Allocator, kind: []const u8, dir: []const u8, owner: []const u8, name: []const u8) !void {
    const git_dir = try std.fmt.allocPrint(a, "{s}/.git", .{dir});
    defer a.free(git_dir);

    if (exists(git_dir)) {
        pullMaybeAuth(a, dir) catch {
            std.debug.print("warn: pull failed, continue\n", .{});
        };
        return;
    }

    if (exists(dir)) {
        std.debug.print("error: {s} path exists but is not a git repo: {s}\n", .{ kind, dir });
        return error.InvalidSourceDir;
    }

    if (std.mem.lastIndexOfScalar(u8, dir, '/')) |i| {
        if (i > 0) try std.fs.cwd().makePath(dir[0..i]);
    }

    std.debug.print("==> {s}: cloning {s}/{s} into {s}\n", .{ kind, owner, name, dir });
    try cloneMaybeAuth(a, owner, name, dir);
}

fn ensureSourceRepo(a: std.mem.Allocator, dir: []const u8, owner: []const u8, name: []const u8) !void {
    return ensureRepo(a, "source", dir, owner, name);
}

fn ensureTapRepo(a: std.mem.Allocator, dir: []const u8, owner: []const u8, name: []const u8) !void {
    return ensureRepo(a, "tap", dir, owner, name);
}

fn pullMaybeAuth(a: std.mem.Allocator, dir: []const u8) !void {
    run(a, &.{ "env", "GIT_TERMINAL_PROMPT=0", "git", "-C", dir, "pull", "--ff-only" }) catch {
        const token = std.posix.getenv("GITHUB_TOKEN") orelse std.posix.getenv("GH_TOKEN") orelse return error.CommandFailed;
        const o = try cap(a, &.{ "git", "-C", dir, "remote", "get-url", "origin" });
        defer a.free(o);
        const old = trim(o);
        if (!std.mem.startsWith(u8, old, "https://github.com/")) return error.CommandFailed;
        const tail = old["https://github.com/".len..];
        const nu = try std.fmt.allocPrint(a, "https://x-access-token:{s}@github.com/{s}", .{ token, tail });
        defer a.free(nu);
        try run(a, &.{ "git", "-C", dir, "remote", "set-url", "origin", nu });
        defer run(a, &.{ "git", "-C", dir, "remote", "set-url", "origin", old }) catch {};
        try run(a, &.{ "env", "GIT_TERMINAL_PROMPT=0", "git", "-C", dir, "pull", "--ff-only" });
    };
}

fn cloneMaybeAuth(a: std.mem.Allocator, owner: []const u8, name: []const u8, dir: []const u8) !void {
    const pub_url = try std.fmt.allocPrint(a, "https://github.com/{s}/{s}", .{ owner, name });
    defer a.free(pub_url);

    run(a, &.{ "env", "GIT_TERMINAL_PROMPT=0", "git", "clone", pub_url, dir }) catch {
        const token = std.posix.getenv("GITHUB_TOKEN") orelse std.posix.getenv("GH_TOKEN") orelse return error.CommandFailed;
        const auth_url = try std.fmt.allocPrint(a, "https://x-access-token:{s}@github.com/{s}/{s}", .{ token, owner, name });
        defer a.free(auth_url);
        try run(a, &.{ "env", "GIT_TERMINAL_PROMPT=0", "git", "clone", auth_url, dir });
        // restore origin URL to clean non-token URL
        try run(a, &.{ "git", "-C", dir, "remote", "set-url", "origin", pub_url });
    };
}

fn pushMaybeAuth(a: std.mem.Allocator, dir: []const u8) !void {
    run(a, &.{ "env", "GIT_TERMINAL_PROMPT=0", "git", "-C", dir, "push" }) catch {
        const token = std.posix.getenv("GITHUB_TOKEN") orelse std.posix.getenv("GH_TOKEN") orelse return error.CommandFailed;
        const o = try cap(a, &.{ "git", "-C", dir, "remote", "get-url", "origin" });
        defer a.free(o);
        const old = trim(o);
        if (!std.mem.startsWith(u8, old, "https://github.com/")) return error.CommandFailed;
        const tail = old["https://github.com/".len..];
        const nu = try std.fmt.allocPrint(a, "https://x-access-token:{s}@github.com/{s}", .{ token, tail });
        defer a.free(nu);
        try run(a, &.{ "git", "-C", dir, "remote", "set-url", "origin", nu });
        defer run(a, &.{ "git", "-C", dir, "remote", "set-url", "origin", old }) catch {};
        try run(a, &.{ "env", "GIT_TERMINAL_PROMPT=0", "git", "-C", dir, "push" });
    };
}

fn parseArgs(a: std.mem.Allocator) !Args {
    var o = Args{};
    const av = try std.process.argsAlloc(a);
    var i: usize = 1;
    while (i < av.len) : (i += 1) {
        const s = av[i];
        if (eq(s, "--repo")) { i += 1; if (i >= av.len) return error.InvalidArguments; o.repo = av[i]; }
        else if (eq(s, "--tap")) { i += 1; if (i >= av.len) return error.InvalidArguments; o.tap = av[i]; }
        else if (eq(s, "--tag")) { i += 1; if (i >= av.len) return error.InvalidArguments; o.tag = av[i]; }
        else if (eq(s, "--formula")) { i += 1; if (i >= av.len) return error.InvalidArguments; o.formula = av[i]; }
        else if (eq(s, "--workdir")) { i += 1; if (i >= av.len) return error.InvalidArguments; o.workdir = av[i]; }
        else if (eq(s, "--tap-dir")) { i += 1; if (i >= av.len) return error.InvalidArguments; o.tap_dir = av[i]; }
        else if (eq(s, "--dry-run")) o.dry = true
        else if (eq(s, "--no-push")) o.no_push = true
        else if (eq(s, "-h") or eq(s, "--help")) { help(); std.process.exit(0); }
        else return error.InvalidArguments;
    }
    return o;
}

fn help() void {
    std.debug.print(
        "toolbox-workflow.zig --repo user/name --tap user/homebrew-tap --tag vX.Y.Z [--formula name] [--workdir path] [--tap-dir path] [--dry-run] [--no-push]\n",
        .{},
    );
}

fn run(a: std.mem.Allocator, argv: []const []const u8) !void { return runIn(a, argv, null); }
fn runIn(a: std.mem.Allocator, argv: []const []const u8, cwd: ?[]const u8) !void {
    const r = try std.process.Child.run(.{ .allocator = a, .argv = argv, .cwd = cwd });
    defer a.free(r.stdout);
    defer a.free(r.stderr);
    switch (r.term) {
        .Exited => |c| if (c != 0) {
            if (r.stdout.len > 0) std.debug.print("{s}\n", .{r.stdout});
            if (r.stderr.len > 0) std.debug.print("{s}\n", .{r.stderr});
            return error.CommandFailed;
        },
        else => return error.CommandFailed,
    }
}

fn cap(a: std.mem.Allocator, argv: []const []const u8) ![]u8 {
    const r = try std.process.Child.run(.{ .allocator = a, .argv = argv });
    defer a.free(r.stderr);
    switch (r.term) {
        .Exited => |c| if (c != 0) { a.free(r.stdout); return error.CommandFailed; },
        else => { a.free(r.stdout); return error.CommandFailed; },
    }
    return r.stdout;
}

fn className(a: std.mem.Allocator, n: []const u8) ![]u8 {
    var o = try std.ArrayList(u8).initCapacity(a, n.len + 4);
    defer o.deinit(a);
    var up = true;
    for (n) |ch| {
        if (ch == '-' or ch == '_' or ch == '.' or ch == ' ') { up = true; continue; }
        if (up and ch >= 'a' and ch <= 'z') try o.append(a, ch - 32) else try o.append(a, ch);
        up = false;
    }
    return o.toOwnedSlice(a);
}

fn eq(a1: []const u8, b: []const u8) bool { return std.mem.eql(u8, a1, b); }
fn trim(s: []const u8) []const u8 { return std.mem.trim(u8, s, " \t\r\n"); }
fn tok(s: []const u8) []const u8 { var i: usize = 0; while (i < s.len and s[i] != ' ' and s[i] != '\t') : (i += 1) {} return s[0..i]; }
fn mustDir(p: []const u8) !void { var d = try std.fs.cwd().openDir(p, .{}); d.close(); }
fn exists(p: []const u8) bool { std.fs.cwd().access(p, .{}) catch return false; return true; }
