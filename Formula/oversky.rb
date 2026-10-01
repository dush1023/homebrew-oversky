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
#   0.8.88                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.88/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   1e235f598978b3709616121a00e5a0804552292dec587b9fa3edf334a599992c       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.88/oversky-darwin-x64, b35bcc28dceb8f00aea564c9f77c3dce8d77e335a1f449f634a4c8b6630b833b
#   https://updates.skrr.ai/daemon/releases/0.8.88/oversky-linux-x64,  a666255396d1261e56efe09f195d7fd89a916fb4bc9cac7937dd940f9b86065a
#   https://updates.skrr.ai/daemon/releases/0.8.88/oversky-linux-arm64, 1bda11157304697582e20f36df27811e0b79575faca27958d159bfdfbabca3df
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
  version "0.8.88"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.88/oversky-darwin-arm64"
      sha256 "1e235f598978b3709616121a00e5a0804552292dec587b9fa3edf334a599992c"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.88/oversky-darwin-x64"
      sha256 "b35bcc28dceb8f00aea564c9f77c3dce8d77e335a1f449f634a4c8b6630b833b"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.88/oversky-linux-arm64"
      sha256 "1bda11157304697582e20f36df27811e0b79575faca27958d159bfdfbabca3df"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.88/oversky-linux-x64"
      sha256 "a666255396d1261e56efe09f195d7fd89a916fb4bc9cac7937dd940f9b86065a"
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
