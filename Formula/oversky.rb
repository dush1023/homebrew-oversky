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
#   0.8.181                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.181/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   da78e88d371267e7b4ee97b1f17e5c71dd55ef5bc1006e89693691b1bd609639       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.181/oversky-darwin-x64, 1ccab1b5d0ae979b8644003d2b215e78115034b7bb7ec321d50735c1c5249a55
#   https://updates.skrr.ai/daemon/releases/0.8.181/oversky-linux-x64,  4c97861eca81549382af59e901282f38f23f50c6bfafb6b2a8ab2441334ec44f
#   https://updates.skrr.ai/daemon/releases/0.8.181/oversky-linux-arm64, a5311540d390ced49734a5ce49602cbef340bc026238cfab773ec798e6eb8e62
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
  version "0.8.181"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.181/oversky-darwin-arm64"
      sha256 "da78e88d371267e7b4ee97b1f17e5c71dd55ef5bc1006e89693691b1bd609639"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.181/oversky-darwin-x64"
      sha256 "1ccab1b5d0ae979b8644003d2b215e78115034b7bb7ec321d50735c1c5249a55"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.181/oversky-linux-arm64"
      sha256 "a5311540d390ced49734a5ce49602cbef340bc026238cfab773ec798e6eb8e62"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.181/oversky-linux-x64"
      sha256 "4c97861eca81549382af59e901282f38f23f50c6bfafb6b2a8ab2441334ec44f"
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
