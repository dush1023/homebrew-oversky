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
#   0.8.5                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.5/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   617b60f95ad44a8a50dde635e93d9af49d583d759b39f1c75afcaed193bfe84c       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.5/oversky-darwin-x64, b911422a7fa5ca6c84c9860d801db7136e6b55154ce499b7b6cdcec607f04ca3
#   https://updates.oversky.ai/daemon/releases/0.8.5/oversky-linux-x64,  5f56336c8e0e0c5ea6d834e563df1ff4a6c9e46310d40f667ed69a7de61c444e
#   https://updates.oversky.ai/daemon/releases/0.8.5/oversky-linux-arm64, 44ddeb47fbdc8f5245e2503458a0d4c48e187dc1b05fd096556d6214a4d67cd6
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
  version "0.8.5"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.5/oversky-darwin-arm64"
      sha256 "617b60f95ad44a8a50dde635e93d9af49d583d759b39f1c75afcaed193bfe84c"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.5/oversky-darwin-x64"
      sha256 "b911422a7fa5ca6c84c9860d801db7136e6b55154ce499b7b6cdcec607f04ca3"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.5/oversky-linux-arm64"
      sha256 "44ddeb47fbdc8f5245e2503458a0d4c48e187dc1b05fd096556d6214a4d67cd6"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.5/oversky-linux-x64"
      sha256 "5f56336c8e0e0c5ea6d834e563df1ff4a6c9e46310d40f667ed69a7de61c444e"
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
