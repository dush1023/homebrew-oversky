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
#   0.8.34                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.34/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   900bd260f74f57ca5b218224ca37847eb6a9726ec60860838e37fe8d346243ce       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.34/oversky-darwin-x64, 478ae04c25341463f68c4405c1b60a02d4a3472450eba3e048fa596d0655cb24
#   https://updates.oversky.ai/daemon/releases/0.8.34/oversky-linux-x64,  de6ea1026d3063e2b7bf791ce08547085a0cb93e07b56caf8763f3a438302e98
#   https://updates.oversky.ai/daemon/releases/0.8.34/oversky-linux-arm64, 5208b8e42775479e1c74a87253ac1e5319dfcc0e04fcfdbe1ae897e249e75c38
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
  version "0.8.34"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.34/oversky-darwin-arm64"
      sha256 "900bd260f74f57ca5b218224ca37847eb6a9726ec60860838e37fe8d346243ce"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.34/oversky-darwin-x64"
      sha256 "478ae04c25341463f68c4405c1b60a02d4a3472450eba3e048fa596d0655cb24"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.34/oversky-linux-arm64"
      sha256 "5208b8e42775479e1c74a87253ac1e5319dfcc0e04fcfdbe1ae897e249e75c38"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.34/oversky-linux-x64"
      sha256 "de6ea1026d3063e2b7bf791ce08547085a0cb93e07b56caf8763f3a438302e98"
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
