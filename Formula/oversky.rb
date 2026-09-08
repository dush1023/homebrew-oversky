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
#   0.8.15                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.15/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   475436b5801befe13b1712fec73fc8520b7430f2505b0faaed8ed19a2d6d1e82       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.15/oversky-darwin-x64, dc658f45f4b686289f99e6f316f003f358dadc84021d7b7d2e11feef2be5f64c
#   https://updates.oversky.ai/daemon/releases/0.8.15/oversky-linux-x64,  1d74858b5467c3691b4811c7fe23abd5c5b8b6f9c3cb1729ed2053d4965b1c1a
#   https://updates.oversky.ai/daemon/releases/0.8.15/oversky-linux-arm64, 2fb7809db82d2249b7adc467650b1e7725d65377095552aeb81c4a2ef417b3e0
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
  version "0.8.15"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.15/oversky-darwin-arm64"
      sha256 "475436b5801befe13b1712fec73fc8520b7430f2505b0faaed8ed19a2d6d1e82"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.15/oversky-darwin-x64"
      sha256 "dc658f45f4b686289f99e6f316f003f358dadc84021d7b7d2e11feef2be5f64c"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.15/oversky-linux-arm64"
      sha256 "2fb7809db82d2249b7adc467650b1e7725d65377095552aeb81c4a2ef417b3e0"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.15/oversky-linux-x64"
      sha256 "1d74858b5467c3691b4811c7fe23abd5c5b8b6f9c3cb1729ed2053d4965b1c1a"
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
