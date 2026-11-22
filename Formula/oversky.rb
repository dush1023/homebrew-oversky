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
#   0.8.182                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.182/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   8bada4e4f9538a52e4d20b17e2791fcc99005b8b4141875c60781d923041e620       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.182/oversky-darwin-x64, 0300c71ad88610b3f32297870f63813ffdfdb797820430da6a86fa033026e20f
#   https://updates.skrr.ai/daemon/releases/0.8.182/oversky-linux-x64,  59afce8aa0c1d90fa4fe6f88e1de20506f8c969a3d4140bb8ca14e660f9b73ae
#   https://updates.skrr.ai/daemon/releases/0.8.182/oversky-linux-arm64, 059ea5e1b5ae0e2c7adb044991c2bd7df857e1c4c31560fff22fdd68fd1584e0
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
  version "0.8.182"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.182/oversky-darwin-arm64"
      sha256 "8bada4e4f9538a52e4d20b17e2791fcc99005b8b4141875c60781d923041e620"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.182/oversky-darwin-x64"
      sha256 "0300c71ad88610b3f32297870f63813ffdfdb797820430da6a86fa033026e20f"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.182/oversky-linux-arm64"
      sha256 "059ea5e1b5ae0e2c7adb044991c2bd7df857e1c4c31560fff22fdd68fd1584e0"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.182/oversky-linux-x64"
      sha256 "59afce8aa0c1d90fa4fe6f88e1de20506f8c969a3d4140bb8ca14e660f9b73ae"
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
