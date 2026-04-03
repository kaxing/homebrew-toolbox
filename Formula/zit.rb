class Zit < Formula
  desc "CLI tool zit"
  homepage "https://github.com/kaxing/zit"
  version "0.0.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zit/releases/download/v0.0.2/zit-darwin-arm64.tar.gz"
      sha256 "60e8b1f4a6de7fc1df6f491d025a9877694f65cc8872c6ad801eacb39a98165c"
    else
      url "https://github.com/kaxing/zit/releases/download/v0.0.2/zit-darwin-amd64.tar.gz"
      sha256 "0e03a2e5e1f2bca99de0bdc4be6bee679685d73b9b7f2216d5fa6075a280531d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zit/releases/download/v0.0.2/zit-linux-arm64.tar.gz"
      sha256 "c7096b72d33d9bd3ea07d18b7f68d02c734521e42379376c1506e8c965f00b84"
    else
      url "https://github.com/kaxing/zit/releases/download/v0.0.2/zit-linux-amd64.tar.gz"
      sha256 "bf2a4160847744a3e6335a7570a895f3d56f60370095a44b398d7e0da2f483a0"
    end
  end

  def install
    bin.install "zit"
  end

  test do
    system "#{bin}/zit", "--clean"
  end
end
