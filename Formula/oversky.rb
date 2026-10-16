# Homebrew formula template for OverSky daemon.
#
# This file is a TEMPLATE. The release workflow (.github/workflows/
# daemon-release.yml, bump-formula job) renders it with the tag's version
# + each asset's sha256 and commits the result to the tap repo at
#   github.com/dush1023/homebrew-oversky:Formula/oversky.rb
#
# The rendered per-arch url/sha256 values point at the PUBLIC CloudFront feed,
# NOT at github.com — the GitHub repo is private, so its Release assets 404 for public
# users. The bump-formula job sets BASE to
#   https://updates.skrr.ai/daemon/releases/<version>
# and each URL resolves to <BASE>/oversky-<platform>-<arch>. Keep that BASE in
# lockstep with scripts/install-daemon.sh's download base. The oversky-* objects
# are the compat stem — the signed manifest names the skrrd-* copies of the same
# bytes, and this formula's checksums come from those entries.
#
# Placeholders (all single-quoted so shell interpolation can't clash):
#   0.8.123                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.123/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   6ac086fa41397119dedfa1e8620e2b87ff77e574f69f7d55a1d43ef32681b109       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.123/oversky-darwin-x64, 77036ff88b926b0c5b4936c8673b4daad313e2d12a26d28a1e16f15e4b37bffe
#   https://updates.skrr.ai/daemon/releases/0.8.123/oversky-linux-x64,  af6e412091985f4f4f0790f37e020e33e32f9be10b82acaa665f3cad5c15b646
#   https://updates.skrr.ai/daemon/releases/0.8.123/oversky-linux-arm64, 79a7e3b1ac163f037f2be2cb7bd56244a2185fb19fec0e98052391630d8018d5
#
# Install path for users (once the tap exists):
#   brew tap dush1023/oversky
#   brew install oversky
#   oversky setup
#
# Upgrade path:
#   brew upgrade oversky
#
# The `oversky setup` command combines login + OS service install into one
# step (see daemon/src/index.ts). Users should never have to edit config
# files manually.

class Oversky < Formula
  desc "Local AI agent executor for OverSky"
  homepage "https://github.com/dush1023/OverSky"
  license "UNLICENSED"
  version "0.8.123"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.123/oversky-darwin-arm64"
      sha256 "6ac086fa41397119dedfa1e8620e2b87ff77e574f69f7d55a1d43ef32681b109"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.123/oversky-darwin-x64"
      sha256 "77036ff88b926b0c5b4936c8673b4daad313e2d12a26d28a1e16f15e4b37bffe"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.123/oversky-linux-arm64"
      sha256 "79a7e3b1ac163f037f2be2cb7bd56244a2185fb19fec0e98052391630d8018d5"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.123/oversky-linux-x64"
      sha256 "af6e412091985f4f4f0790f37e020e33e32f9be10b82acaa665f3cad5c15b646"
    end
  end

  def install
    # Bun-compiled binaries ship as a single file named by platform + arch.
    # Normalize to "oversky" at install time so the tap's entry point is
    # stable regardless of the user's platform.
    binaries = Dir["oversky-*"]
    odie "no oversky-* binary in release asset" if binaries.empty?
    odie "multiple oversky-* binaries in release asset: #{binaries}" if binaries.size > 1
    bin.install binaries.first => "oversky"
  end

  test do
    # Smoke test — verifies the binary loads and the embedded version
    # matches the formula version. If this ever drifts, the release
    # workflow is broken.
    assert_match version.to_s, shell_output("#{bin}/oversky --version")
  end
end
