class Zit < Formula
  desc "CLI tool zit"
  homepage "https://github.com/kaxing/zit"
  version "0.0.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zit/releases/download/v0.0.2/zit-darwin-arm64.tar.gz"
      sha256 "a9d39ec537a4e8b36a1c4a3a9e90b05d8b2be9206650b5d3a945f96c1cccce4c"
    else
      url "https://github.com/kaxing/zit/releases/download/v0.0.2/zit-darwin-amd64.tar.gz"
      sha256 "a10ccef2db295820270c0386c3e51bd9d441ed34f36b59c40f118134af58a5b8"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zit/releases/download/v0.0.2/zit-linux-arm64.tar.gz"
      sha256 "af99dd7c8f984bb0d2fc2506e0a8a3dcf97ea76d635205cfcef39a1b8b629432"
    else
      url "https://github.com/kaxing/zit/releases/download/v0.0.2/zit-linux-amd64.tar.gz"
      sha256 "652e374532f2ccd52cc910c0c47b5f73614fa83bd1dd0e26d5c6333db6677162"
    end
  end

  def install
    bin.install "zit"
  end

  test do
    system "#{bin}/zit", "--clean"
  end
end
