class Check < Formula
  desc "CLI tool checkpoint"
  homepage "https://github.com/kaxing/checkpoint"
  version "0.0.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/checkpoint/releases/download/v0.0.3/checkpoint-darwin-arm64.tar.gz"
      sha256 "dadfc7c37ff87e565a32dd3ad579979250470727186f7148876c582567a39c09"
    else
      url "https://github.com/kaxing/checkpoint/releases/download/v0.0.3/checkpoint-darwin-amd64.tar.gz"
      sha256 "6261f166ac53d9a5d95503349cebf8abec15d6f4bcce98b5992e5710fbe6f4bd"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/checkpoint/releases/download/v0.0.3/checkpoint-linux-arm64.tar.gz"
      sha256 "c184e13715a7345f06fec5cd2dd345578d813333578899144460862bdc05aaa4"
    else
      url "https://github.com/kaxing/checkpoint/releases/download/v0.0.3/checkpoint-linux-amd64.tar.gz"
      sha256 "00b7a4626978fee93b5c67d857f9e9a93c8c62c03e757aa11a441ddeea1c24e1"
    end
  end

  def install
    bin.install "check"
  end

  test do
    system "#{bin}/check", "--clean"
  end
end
