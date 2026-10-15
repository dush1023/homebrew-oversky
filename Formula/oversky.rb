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
#   0.8.119                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.119/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   5ad53feb27d8d902445babaa3b6fbee76da2cd3117c5e13a01c14487eb0a3336       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.119/oversky-darwin-x64, c46a352daeffd8d8d9ea814e551e91ec9ac6330dedf7eeb1daffb0a36a42b7ef
#   https://updates.skrr.ai/daemon/releases/0.8.119/oversky-linux-x64,  ee75c67560f5a1070e0b4b94c2484e5b967e4c21079376e99dc8d2ce1b37e68d
#   https://updates.skrr.ai/daemon/releases/0.8.119/oversky-linux-arm64, 57d65e63966d6d8094f3b9fe7664ad7219bae85be81c6b90cd87865dee4125db
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
  version "0.8.119"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.119/oversky-darwin-arm64"
      sha256 "5ad53feb27d8d902445babaa3b6fbee76da2cd3117c5e13a01c14487eb0a3336"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.119/oversky-darwin-x64"
      sha256 "c46a352daeffd8d8d9ea814e551e91ec9ac6330dedf7eeb1daffb0a36a42b7ef"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.119/oversky-linux-arm64"
      sha256 "57d65e63966d6d8094f3b9fe7664ad7219bae85be81c6b90cd87865dee4125db"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.119/oversky-linux-x64"
      sha256 "ee75c67560f5a1070e0b4b94c2484e5b967e4c21079376e99dc8d2ce1b37e68d"
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
