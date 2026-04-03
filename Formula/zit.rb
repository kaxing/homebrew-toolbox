class Zit < Formula
  desc "CLI tool zit"
  homepage "https://github.com/kaxing/zit"
  version "0.0.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zit/releases/download/v0.0.1/zit-darwin-arm64.tar.gz"
      sha256 "4463e13b27586b3a1af3ddc052a80314b087fdee021ec7c5d2b82d05297e2bce"
    else
      url "https://github.com/kaxing/zit/releases/download/v0.0.1/zit-darwin-amd64.tar.gz"
      sha256 "c4a5a6d36603b25f356723578de9ce3096a3606c677936ec48fb3a4089dc7fd7"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zit/releases/download/v0.0.1/zit-linux-arm64.tar.gz"
      sha256 "beabe9ec614522115f74b591d91fe293e4a1c617d76bda5a7024cb7af804165a"
    else
      url "https://github.com/kaxing/zit/releases/download/v0.0.1/zit-linux-amd64.tar.gz"
      sha256 "eeba39404120477eb2c2f84edd6c1fbd2ec0b19cb5d59eed9a077b4f0e80cd2e"
    end
  end

  def install
    bin.install "zit"
  end

  test do
    system "#{bin}/zit", "--clean"
  end
end
