class Zur < Formula
  desc "CLI tool zur"
  homepage "https://github.com/kaxing/zur"
  version "0.0.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zur/releases/download/v0.0.1/zur-darwin-arm64.tar.gz"
      sha256 "c2e0c79b86e37e1be9fd2ab0693ff0d2e1d7bf0d5d2cd949a58aaaaf5f6426db"
    else
      url "https://github.com/kaxing/zur/releases/download/v0.0.1/zur-darwin-amd64.tar.gz"
      sha256 "f49b28dbc66a364152414a1618712bcad96929c9448a457758413400f8194ed7"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zur/releases/download/v0.0.1/zur-linux-arm64.tar.gz"
      sha256 "797a12a62050c5de0e7b5d93a960c7d50c5dfe7c358ecf0f75aad5680ecdc38a"
    else
      url "https://github.com/kaxing/zur/releases/download/v0.0.1/zur-linux-amd64.tar.gz"
      sha256 "4231502baedd7369cb7fb561c5b8fd6924c79e016a77426e941a5b26f40f7a7d"
    end
  end

  def install
    bin.install "zur"
  end

  test do
    system "#{bin}/zur", "--clean"
  end
end
