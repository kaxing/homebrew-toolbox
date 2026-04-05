class Zur < Formula
  desc "CLI tool zur"
  homepage "https://github.com/kaxing/zur"
  version "0.0.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zur/releases/download/v0.0.2/zur-darwin-arm64.tar.gz"
      sha256 "d4b15730612cec886d9d6b2de3bc3e557e43725974d76fb77aea96eca5d66b69"
    else
      url "https://github.com/kaxing/zur/releases/download/v0.0.2/zur-darwin-amd64.tar.gz"
      sha256 "1ba2e86eed53e0b95aa6c30511377a20b9ef675573d127e4b24f18fb55327b8c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zur/releases/download/v0.0.2/zur-linux-arm64.tar.gz"
      sha256 "900619ecc3c898e4cf57d74f1d2ed00b5931563634776ef2f75d5cd15e677e17"
    else
      url "https://github.com/kaxing/zur/releases/download/v0.0.2/zur-linux-amd64.tar.gz"
      sha256 "12abb412466f2eb1fe22b0b760597059820df4ccab698f95fe5ddbf611de47e1"
    end
  end

  def install
    bin.install "zur"
  end

  test do
    system "#{bin}/zur", "--clean"
  end
end
