class Zit < Formula
  desc "CLI tool zit"
  homepage "https://github.com/kaxing/zit"
  version "0.0.4"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zit/releases/download/v0.0.4/zit-darwin-arm64.tar.gz"
      sha256 "3611a76dda62b8b34ba2038b12385abec34d5d3626a3236c1fd2408541cfa096"
    else
      url "https://github.com/kaxing/zit/releases/download/v0.0.4/zit-darwin-amd64.tar.gz"
      sha256 "09cfcb8d0ed122b1c74ed8978f0f1a759657b4f08801fa1ec8932e4128314d43"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/kaxing/zit/releases/download/v0.0.4/zit-linux-arm64.tar.gz"
      sha256 "db92f6c02c9a4dae32827e38e4c204f00a00f41afaeac19bad8822b1bde0bb9b"
    else
      url "https://github.com/kaxing/zit/releases/download/v0.0.4/zit-linux-amd64.tar.gz"
      sha256 "63d5a1f82328f6699d9e27aa2f790553858026cfd533e071cdedd414756ed249"
    end
  end

  def install
    bin.install "zit"
  end

  test do
    system "#{bin}/zit", "--clean"
  end
end
