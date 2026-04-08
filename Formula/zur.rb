class Zur < Formula
  desc "CLI tool zur"
  homepage "https://github.com/kaxing/zur"
  version "0.0.4"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zur/releases/download/v0.0.4/zur-darwin-arm64.tar.gz"
      sha256 "e7bf74e2212df98f11cbe088f8cff0c0da3543efcecb1f83c7c642caefbbd2be"
    else
      url "https://github.com/kaxing/zur/releases/download/v0.0.4/zur-darwin-amd64.tar.gz"
      sha256 "22e459e4e30194f23a7349cbe6ffdfad181e2ec2a1cef7156a3077fbbc2bceb8"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zur/releases/download/v0.0.4/zur-linux-arm64.tar.gz"
      sha256 "c7222f5500d45ea49724292b98a292c5616fa76696d94c745547df30ab9f0e69"
    else
      url "https://github.com/kaxing/zur/releases/download/v0.0.4/zur-linux-amd64.tar.gz"
      sha256 "b22ced6ef7f8390bdc46b79b4af68bb70ad43702f4c75a4d52f16c8baa45a624"
    end
  end

  def install
    bin.install "zur"
  end

  test do
    system "#{bin}/zur", "--clean"
  end
end
