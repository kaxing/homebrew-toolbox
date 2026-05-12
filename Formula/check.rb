class Check < Formula
  desc "CLI tool checkpoint"
  homepage "https://github.com/kaxing/checkpoint"
  version "0.0.4"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/checkpoint/releases/download/v0.0.4/checkpoint-darwin-arm64.tar.gz"
      sha256 "680fe279128e32bfb7dbbc9a1c02579b62ef4975d734fb743a77ad344974aed1"
    else
      url "https://github.com/kaxing/checkpoint/releases/download/v0.0.4/checkpoint-darwin-amd64.tar.gz"
      sha256 "ff893320f767b14eef67b3f678e22c3449c37f173cefdc3749094346895d11ab"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/checkpoint/releases/download/v0.0.4/checkpoint-linux-arm64.tar.gz"
      sha256 "e65c7c8a115c7d636a55274cf6ce0374364a167e5a8adc7aada253fb9949c3ef"
    else
      url "https://github.com/kaxing/checkpoint/releases/download/v0.0.4/checkpoint-linux-amd64.tar.gz"
      sha256 "dd119b9af16f868edb645f36975591786a465500a23390d334ec1b8358d77497"
    end
  end

  def install
    bin.install "check"
  end

  test do
    system "#{bin}/check", "--clean"
  end
end
