class Zur < Formula
  desc "CLI tool zur"
  homepage "https://github.com/kaxing/zur"
  version "0.0.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zur/releases/download/v0.0.3/zur-darwin-arm64.tar.gz"
      sha256 "57a074a0f64edb71a6983fd893aca916d27227eb2607ded58b2f89bfb681ee11"
    else
      url "https://github.com/kaxing/zur/releases/download/v0.0.3/zur-darwin-amd64.tar.gz"
      sha256 "a3a607685510a9abf5867c469e2aacd766184cd4091b928b13fc081d1deaf007"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zur/releases/download/v0.0.3/zur-linux-arm64.tar.gz"
      sha256 "51224025651eb4bb2add49a354201677d32dca0e91093b11ba9f75a3a5f7d76d"
    else
      url "https://github.com/kaxing/zur/releases/download/v0.0.3/zur-linux-amd64.tar.gz"
      sha256 "3cd0a8d1b000a0a0e37582af59331555354bf10db305f435c9e95b883655cfde"
    end
  end

  def install
    bin.install "zur"
  end

  test do
    system "#{bin}/zur", "--clean"
  end
end
