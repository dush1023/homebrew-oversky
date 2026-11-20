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
#   0.8.175                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.175/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   f1cddd578d7a1a26726198f0277fa7cdb792393a6e517eb65b90b34e23494c8e       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.175/oversky-darwin-x64, 913283a08f64ac00a34c389e4f6f2200df00e3da94685e07cf68ccc30574d886
#   https://updates.skrr.ai/daemon/releases/0.8.175/oversky-linux-x64,  79424760d1d82dc954e7892b5dcf8cc31880d1f0650b65034e17775a30411454
#   https://updates.skrr.ai/daemon/releases/0.8.175/oversky-linux-arm64, 7d20b03e75469494e76ba94f9eb4834b4b19254c8972445ac2fa3d197f14814a
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
  homepage "https://github.com/skrr-ai/OverSky"
  license "UNLICENSED"
  version "0.8.175"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.175/oversky-darwin-arm64"
      sha256 "f1cddd578d7a1a26726198f0277fa7cdb792393a6e517eb65b90b34e23494c8e"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.175/oversky-darwin-x64"
      sha256 "913283a08f64ac00a34c389e4f6f2200df00e3da94685e07cf68ccc30574d886"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.175/oversky-linux-arm64"
      sha256 "7d20b03e75469494e76ba94f9eb4834b4b19254c8972445ac2fa3d197f14814a"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.175/oversky-linux-x64"
      sha256 "79424760d1d82dc954e7892b5dcf8cc31880d1f0650b65034e17775a30411454"
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
