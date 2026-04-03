class Zit < Formula
  desc "CLI tool zit"
  homepage "https://github.com/kaxing/zit"
  version "0.0.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zit/releases/download/v0.0.1/zit-darwin-arm64.tar.gz"
      sha256 "e169b350d32f5a683d5a3c41f469a713a23e785829002391acb4475ed2a9fffd"
    else
      url "https://github.com/kaxing/zit/releases/download/v0.0.1/zit-darwin-amd64.tar.gz"
      sha256 "dd2f9693fa5958cc8865923a7227fa6a25bbfa7fa1334b92e4832d8d20b8d2e7"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zit/releases/download/v0.0.1/zit-linux-arm64.tar.gz"
      sha256 "e81819aa03031b8b8a2145a92a3e56dc7518230b39371b73943dcbedb6942034"
    else
      url "https://github.com/kaxing/zit/releases/download/v0.0.1/zit-linux-amd64.tar.gz"
      sha256 "2018b5357fbd7a7fa798b56a0ca7001eb6c404231a4a1f6115d2d2799553013f"
    end
  end

  def install
    bin.install "zit"
  end

  test do
    system "#{bin}/zit", "--clean"
  end
end
