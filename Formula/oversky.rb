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
#   https://updates.oversky.ai/daemon/releases/<version>
# and each URL resolves to <BASE>/oversky-<platform>-<arch>. Keep that BASE in
# lockstep with scripts/install-daemon.sh's download base.
#
# Placeholders (all single-quoted so shell interpolation can't clash):
#   0.8.35                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.35/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   8d97aff3b536442774ee585f8ef2213b50d14921a30fc19766e8eb5e9ff7e642       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.35/oversky-darwin-x64, aecc4132fa353894c899e9e53b1841acbd6e9645eecac13f3c4e84fb80fe7275
#   https://updates.oversky.ai/daemon/releases/0.8.35/oversky-linux-x64,  c81f3c5494d90e7e3ce0f8239a5806743999818709b96700c5f978b201e8364a
#   https://updates.oversky.ai/daemon/releases/0.8.35/oversky-linux-arm64, d6553e5f0b100a5895d3d18b7baed21f016df520537ca56b204dcdae5321264a
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
  version "0.8.35"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.35/oversky-darwin-arm64"
      sha256 "8d97aff3b536442774ee585f8ef2213b50d14921a30fc19766e8eb5e9ff7e642"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.35/oversky-darwin-x64"
      sha256 "aecc4132fa353894c899e9e53b1841acbd6e9645eecac13f3c4e84fb80fe7275"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.35/oversky-linux-arm64"
      sha256 "d6553e5f0b100a5895d3d18b7baed21f016df520537ca56b204dcdae5321264a"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.35/oversky-linux-x64"
      sha256 "c81f3c5494d90e7e3ce0f8239a5806743999818709b96700c5f978b201e8364a"
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
