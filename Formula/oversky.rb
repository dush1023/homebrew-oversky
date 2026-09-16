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
#   0.8.45                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.45/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   2263edfb5bae8da66f725a433b745407a8e2a5c4a6fac91139f471fab5d947aa       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.45/oversky-darwin-x64, 12ecc8e950887d51663b91653ba220076bda2988799f03e2e747a45e62726ee2
#   https://updates.oversky.ai/daemon/releases/0.8.45/oversky-linux-x64,  cc33dcf98d5811b9f1e37732c37407cc0fdb24c6c4b987883efa9d07204f1b77
#   https://updates.oversky.ai/daemon/releases/0.8.45/oversky-linux-arm64, fe95208e17e8df4a1a82fd3117b03140525ecff865aee4b2d962e2bef2701fdb
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
  version "0.8.45"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.45/oversky-darwin-arm64"
      sha256 "2263edfb5bae8da66f725a433b745407a8e2a5c4a6fac91139f471fab5d947aa"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.45/oversky-darwin-x64"
      sha256 "12ecc8e950887d51663b91653ba220076bda2988799f03e2e747a45e62726ee2"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.45/oversky-linux-arm64"
      sha256 "fe95208e17e8df4a1a82fd3117b03140525ecff865aee4b2d962e2bef2701fdb"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.45/oversky-linux-x64"
      sha256 "cc33dcf98d5811b9f1e37732c37407cc0fdb24c6c4b987883efa9d07204f1b77"
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
