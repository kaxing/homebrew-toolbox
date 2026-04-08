class Zur < Formula
  desc "CLI tool zur"
  homepage "https://github.com/kaxing/zur"
  version "0.0.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zur/releases/download/v0.0.3/zur-darwin-arm64.tar.gz"
      sha256 "022e5bd58db76c287149c4e2aed7b126515b65cf8af8305d19d4c7705385aabe"
    else
      url "https://github.com/kaxing/zur/releases/download/v0.0.3/zur-darwin-amd64.tar.gz"
      sha256 "c0d176491e95c8ae84ab5f9c2c99fcbfd2be8fe9fa0c96406d925c74854ee321"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zur/releases/download/v0.0.3/zur-linux-arm64.tar.gz"
      sha256 "2f0271829c5cce2cd5c3278d0de6cfc3f3c263335ba687bb3b3cb866a905b1ce"
    else
      url "https://github.com/kaxing/zur/releases/download/v0.0.3/zur-linux-amd64.tar.gz"
      sha256 "f6b67ddb51a7b08905dfa58912e58c81383d8eeac9166b09f32233a0dcef83e6"
    end
  end

  def install
    bin.install "zur"
  end

  test do
    system "#{bin}/zur", "--clean"
  end
end
