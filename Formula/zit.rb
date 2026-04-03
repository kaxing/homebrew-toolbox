class Zit < Formula
  desc "CLI tool zit"
  homepage "https://github.com/kaxing/zit"
  version "0.0.5"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zit/releases/download/v0.0.5/zit-darwin-arm64.tar.gz"
      sha256 "bd056c149206eafcbb7618b0a3e76b7ac00a4526e6548baa7e4cc75a2179a293"
    else
      url "https://github.com/kaxing/zit/releases/download/v0.0.5/zit-darwin-amd64.tar.gz"
      sha256 "cd9174401ba21fbfe4333621e005907ef16dee889d479c93f207b585daba9dbb"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zit/releases/download/v0.0.5/zit-linux-arm64.tar.gz"
      sha256 "e78a555d01365f2f90b5adb9ad1b10261192b7b102aa0db7f27521aadde5e9c4"
    else
      url "https://github.com/kaxing/zit/releases/download/v0.0.5/zit-linux-amd64.tar.gz"
      sha256 "ce6db0fa8a57d3e788f20493ffb2fde6d2bb588913e0f899db4a0e0d8186531c"
    end
  end

  def install
    bin.install "zit"
  end

  test do
    system "#{bin}/zit", "--clean"
  end
end
