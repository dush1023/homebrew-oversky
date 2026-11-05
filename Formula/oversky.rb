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
#   0.8.149                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.149/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   d0d184534e3dba39d42feb89af7986037b7c887f95bbd4e765035c666a0239a1       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.149/oversky-darwin-x64, 76cea27c08def151774786811692f9608bed150db658f1e997ecf47d82c08bdd
#   https://updates.skrr.ai/daemon/releases/0.8.149/oversky-linux-x64,  e6c9f6393185103d3b263c434aeafd67694b98a40a44fd7623d8cbdfb2d59b86
#   https://updates.skrr.ai/daemon/releases/0.8.149/oversky-linux-arm64, 02d88dfbb0e014a45b2e3780095caaf4d026563303634c3673bd7ec7a6a21e0c
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
  version "0.8.149"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.149/oversky-darwin-arm64"
      sha256 "d0d184534e3dba39d42feb89af7986037b7c887f95bbd4e765035c666a0239a1"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.149/oversky-darwin-x64"
      sha256 "76cea27c08def151774786811692f9608bed150db658f1e997ecf47d82c08bdd"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.149/oversky-linux-arm64"
      sha256 "02d88dfbb0e014a45b2e3780095caaf4d026563303634c3673bd7ec7a6a21e0c"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.149/oversky-linux-x64"
      sha256 "e6c9f6393185103d3b263c434aeafd67694b98a40a44fd7623d8cbdfb2d59b86"
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
