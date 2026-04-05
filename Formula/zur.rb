class Zur < Formula
  desc "CLI tool zur"
  homepage "https://github.com/kaxing/zur"
  version "0.0.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zur/releases/download/v0.0.2/zur-darwin-arm64.tar.gz"
      sha256 "0774f472c31cbef2fdf201a37b057d3b08fd6cca07a758a28b64ebf5cd031f73"
    else
      url "https://github.com/kaxing/zur/releases/download/v0.0.2/zur-darwin-amd64.tar.gz"
      sha256 "42498082440114863b66f3c3009c89c3ffcb9c0518f533e9574444d0f9766ded"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zur/releases/download/v0.0.2/zur-linux-arm64.tar.gz"
      sha256 "87c36a44c86a184494597b474f766e8bedea3abd57f4a0d4227091b6348c49c1"
    else
      url "https://github.com/kaxing/zur/releases/download/v0.0.2/zur-linux-amd64.tar.gz"
      sha256 "928a287c8a8095f4ac49c8ecb4888db92de9ee8de8c1ef9be1e91dc8239ffd9a"
    end
  end

  def install
    bin.install "zur"
  end

  test do
    system "#{bin}/zur", "--clean"
  end
end
