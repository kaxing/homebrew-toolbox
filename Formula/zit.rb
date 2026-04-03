class Zit < Formula
  desc "CLI tool zit"
  homepage "https://github.com/kaxing/zit"
  version "0.0.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zit/releases/download/v0.0.3/zit-darwin-arm64.tar.gz"
      sha256 "43f3f791e44267d77d5f1b772fec434dcd9e6509af87a1d399d2a569485fecac"
    else
      url "https://github.com/kaxing/zit/releases/download/v0.0.3/zit-darwin-amd64.tar.gz"
      sha256 "9a27e3d452c81e91b7fb03c394ddd2806db80d0cb21e6df04fd11f15798a166a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zit/releases/download/v0.0.3/zit-linux-arm64.tar.gz"
      sha256 "d37dc516098c3b6cba8a051a5a8c9046ac95eda8d819c398b40d444e21a37b63"
    else
      url "https://github.com/kaxing/zit/releases/download/v0.0.3/zit-linux-amd64.tar.gz"
      sha256 "9945453130404e9a96bd806904e09ff16160137d82fbcc1757ddeac5ea6d7e94"
    end
  end

  def install
    bin.install "zit"
  end

  test do
    system "#{bin}/zit", "--clean"
  end
end
