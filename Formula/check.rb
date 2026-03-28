class Check < Formula
  desc "CLI tool checkpoint"
  homepage "https://github.com/kaxing/checkpoint"
  version "0.0.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/checkpoint/releases/download/v0.0.1/checkpoint-darwin-arm64.tar.gz"
      sha256 "303953554ddbb6a3777cc4d9fd8661ab1b90ca1a7205eed6e8e4cf412fb23def"
    else
      url "https://github.com/kaxing/checkpoint/releases/download/v0.0.1/checkpoint-darwin-amd64.tar.gz"
      sha256 "cf7df8879105a980e4fccefa02ce035c8d51c39a30e5dd7957caa5190490044c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/checkpoint/releases/download/v0.0.1/checkpoint-linux-arm64.tar.gz"
      sha256 "f3d10614f9acfb0dd4a0d423eb4860d0f56ac32e677c8f4dd123215700789675"
    else
      url "https://github.com/kaxing/checkpoint/releases/download/v0.0.1/checkpoint-linux-amd64.tar.gz"
      sha256 "3c3e9088fe7bd5b1ee7dc5ebb9b3e33b04d163053394396ce3b24cd0f9190939"
    end
  end

  def install
    bin.install "check"
  end

  test do
    system "#{bin}/check", "--clean"
  end
end
