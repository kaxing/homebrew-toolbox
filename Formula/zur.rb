class Zur < Formula
  desc "CLI tool zur"
  homepage "https://github.com/kaxing/zur"
  version "0.0.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zur/releases/download/v0.0.1/zur-darwin-arm64.tar.gz"
      sha256 "cef802948df74a1416da79cafcb5dba2e39648d4b266e6d3eba33bc0245ea0e5"
    else
      url "https://github.com/kaxing/zur/releases/download/v0.0.1/zur-darwin-amd64.tar.gz"
      sha256 "60d89afd0ace0e4b476462f7bf3c84cc9fc9dc3ab2478318f7f1fe2188207f49"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zur/releases/download/v0.0.1/zur-linux-arm64.tar.gz"
      sha256 "a35a4ecfcfbb037126fae6a56557f19bf10fa41e72babf5e8725fb9f2170490c"
    else
      url "https://github.com/kaxing/zur/releases/download/v0.0.1/zur-linux-amd64.tar.gz"
      sha256 "1addc512ad92d54f80f262b6afce2589b0f7d01024d188f1d7ad55abd36e87b2"
    end
  end

  def install
    bin.install "zur"
  end

  test do
    system "#{bin}/zur", "--clean"
  end
end
