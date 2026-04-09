class Zur < Formula
  desc "CLI tool zur"
  homepage "https://github.com/kaxing/zur"
  version "0.0.5"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zur/releases/download/v0.0.5/zur-darwin-arm64.tar.gz"
      sha256 "47df89569929e0637cca4b019ff12677009e41ed13fdb03ebbe4d2f1bcb260bd"
    else
      url "https://github.com/kaxing/zur/releases/download/v0.0.5/zur-darwin-amd64.tar.gz"
      sha256 "c73db498799ee3b7ea6dd2da1ce7c9bb26f6a92f124a834c70e4d4b56265ff07"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zur/releases/download/v0.0.5/zur-linux-arm64.tar.gz"
      sha256 "1b739a659b5854173af880a77ae1497babfb1b6684a8d7f8182f11aa22b8fbf2"
    else
      url "https://github.com/kaxing/zur/releases/download/v0.0.5/zur-linux-amd64.tar.gz"
      sha256 "2312d03faaf0e1433d907737119b6bb6aa113a8335b632c36af00fcee4f6d1c3"
    end
  end

  def install
    bin.install "zur"
  end

  test do
    system "#{bin}/zur", "--clean"
  end
end
