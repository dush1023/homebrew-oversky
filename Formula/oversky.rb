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
#   0.8.90                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.90/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   3e294bd1080d372a509b71629272e93295b52fa3fd6b57ccfbb5b10b1bda0e4b       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.90/oversky-darwin-x64, 20b19117b77863a33aeaf6ee0a541bf8b69d27acc0d217a0f553c5f79dcea3dc
#   https://updates.skrr.ai/daemon/releases/0.8.90/oversky-linux-x64,  877315fd8dd16d5d730a901f2daccda0f124a97c27a925dbe7fa4ec95bff4acc
#   https://updates.skrr.ai/daemon/releases/0.8.90/oversky-linux-arm64, 6e32a175b0b6edcb25fe71cd703212c17911d709fc8b2ac6b27b129b6c52cc4c
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
  version "0.8.90"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.90/oversky-darwin-arm64"
      sha256 "3e294bd1080d372a509b71629272e93295b52fa3fd6b57ccfbb5b10b1bda0e4b"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.90/oversky-darwin-x64"
      sha256 "20b19117b77863a33aeaf6ee0a541bf8b69d27acc0d217a0f553c5f79dcea3dc"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.90/oversky-linux-arm64"
      sha256 "6e32a175b0b6edcb25fe71cd703212c17911d709fc8b2ac6b27b129b6c52cc4c"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.90/oversky-linux-x64"
      sha256 "877315fd8dd16d5d730a901f2daccda0f124a97c27a925dbe7fa4ec95bff4acc"
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
