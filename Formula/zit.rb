class Zit < Formula
  desc "Run Zig source files like scripts with caching"
  homepage "https://github.com/kaxing/zit"
  version "0.0.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zit/releases/download/v0.0.1/zit-darwin-arm64.tar.gz"
      sha256 "3ad645aa1ad191f0e089e3c224c210788bec811857370bc60ad624b24da4c5f9"
    else
      url "https://github.com/kaxing/zit/releases/download/v0.0.1/zit-darwin-amd64.tar.gz"
      sha256 "5938225000598934cdadcb605c6328eff1d8c78421470d0593eb0ad19a0c8f4e"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zit/releases/download/v0.0.1/zit-linux-arm64.tar.gz"
      sha256 "b5afc16ff3c738024ce0316542adcb0918ce77bf982137f2840a4bca69cbc320"
    else
      url "https://github.com/kaxing/zit/releases/download/v0.0.1/zit-linux-amd64.tar.gz"
      sha256 "e08994586466da6bc956a89f17504fa5307e94230291e98bfcb507148481704e"
    end
  end

  def install
    bin.install "zit"
  end

  test do
    system "#{bin}/zit", "--clean"
  end
end
