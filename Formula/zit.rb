class Zit < Formula
  desc "Run Zig source files like scripts with caching"
  homepage "https://github.com/kaxing/zit"
  url "https://github.com/kaxing/zit/archive/99b4be1f75b6a925e4a371bee4f803439de45beb.tar.gz"
  sha256 "4189250af360ae1f3cced149cd83eef48ffa6a91dc4c4b4ec7b48d0f9b173567"
  license "MIT"

  depends_on "zig" => :build

  def install
    system "make"
    bin.install "zit"
  end

  test do
    system "#{bin}/zit", "--clean"
  end
end

