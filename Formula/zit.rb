class Zit < Formula
  desc "CLI tool zit"
  homepage "https://github.com/kaxing/zit"
  version "0.0.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zit/releases/download/v0.0.1/zit-darwin-arm64.tar.gz"
      sha256 "ade952b8649a6f6c9b61920a6959249033ffb506142b5fcdf0c40a35347af037"
    else
      url "https://github.com/kaxing/zit/releases/download/v0.0.1/zit-darwin-amd64.tar.gz"
      sha256 "7b676c939104911cafa8999025ce3a27aa4b16b65c9bbbc35722ef729af187d6"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zit/releases/download/v0.0.1/zit-linux-arm64.tar.gz"
      sha256 "0624cd9c9d530ebd51cc6027963939b878d71baa879b5f4639da4b49ede9331c"
    else
      url "https://github.com/kaxing/zit/releases/download/v0.0.1/zit-linux-amd64.tar.gz"
      sha256 "5f5aae87c2420979f91f62a303e22952b3779ffb1d3acb19a6d3d057aac05ec6"
    end
  end

  def install
    bin.install "zit"
  end

  test do
    system "#{bin}/zit", "--clean"
  end
end
