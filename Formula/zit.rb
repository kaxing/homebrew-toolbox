class Zit < Formula
  desc "Run Zig source files like scripts with caching"
  homepage "https://github.com/kaxing/zit"
  url "https://github.com/kaxing/zit/archive/f53cd7046716e14639034f0217b5e8435d754854.tar.gz"
  sha256 "4f0e086e1de15e219c56a77a7c82988c1ea17369e20b105c36e72efbc12c180f"
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
