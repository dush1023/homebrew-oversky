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
#   0.8.7                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.7/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   b6f5037a091a8c25bf5a2d17d93066dfc464ce77e81fc69247bb316bab883625       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.7/oversky-darwin-x64, 3b09ee3ebc743db4b48a698225a0a081155c0a459ea5b547bd566ce96701b32f
#   https://updates.oversky.ai/daemon/releases/0.8.7/oversky-linux-x64,  c99351a8455b67285641858879e80e9c372127592aba9de435688a686e29ceb7
#   https://updates.oversky.ai/daemon/releases/0.8.7/oversky-linux-arm64, 26b68b224161bdbb6c5f4a9809d1855ead8b8ba4dd15f192d3f3f3c511fc526c
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
  version "0.8.7"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.7/oversky-darwin-arm64"
      sha256 "b6f5037a091a8c25bf5a2d17d93066dfc464ce77e81fc69247bb316bab883625"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.7/oversky-darwin-x64"
      sha256 "3b09ee3ebc743db4b48a698225a0a081155c0a459ea5b547bd566ce96701b32f"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.7/oversky-linux-arm64"
      sha256 "26b68b224161bdbb6c5f4a9809d1855ead8b8ba4dd15f192d3f3f3c511fc526c"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.7/oversky-linux-x64"
      sha256 "c99351a8455b67285641858879e80e9c372127592aba9de435688a686e29ceb7"
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
