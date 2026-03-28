class Zit < Formula
  desc "CLI tool zit"
  homepage "https://github.com/kaxing/zit"
  version "0.0.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zit/releases/download/v0.0.1/zit-darwin-arm64.tar.gz"
      sha256 "29c26bd856f3ff04214ce232d3b975f819f292c62da72cc15152754cb02856c0"
    else
      url "https://github.com/kaxing/zit/releases/download/v0.0.1/zit-darwin-amd64.tar.gz"
      sha256 "008a95d7da18ff4eb19065e6043b1733b916c80fb96991f72e4a4008c0b6edcd"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zit/releases/download/v0.0.1/zit-linux-arm64.tar.gz"
      sha256 "9fb8885fea5d8e690799226760e12d2fcde5eb5946f8298d23a79c40b6de9492"
    else
      url "https://github.com/kaxing/zit/releases/download/v0.0.1/zit-linux-amd64.tar.gz"
      sha256 "e9a0948d4286d9d5f31410c3b22fd08f00ac78d24838b8ff3b84aaf6bdf49bda"
    end
  end

  def install
    bin.install "zit"
  end

  test do
    system "#{bin}/zit", "--clean"
  end
end
