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
#   0.8.183                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.183/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   a413755f72bb0a24a2cdf5bcfeb90c411cd7820c144eea4f91c182a8520f6711       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.183/oversky-darwin-x64, 6466d1d96fbdf1e526e740bf05aa8aad4e6847560fd214efb0c4223fe86f0274
#   https://updates.skrr.ai/daemon/releases/0.8.183/oversky-linux-x64,  da99d26bb1fb0cbabd999a7e300c96ca95fecee1b7c2aa412c9362c2d07f5e0d
#   https://updates.skrr.ai/daemon/releases/0.8.183/oversky-linux-arm64, 8723d4371ad95fbfe9a9daeb496f84fac4c10a72413f371087ea3e7aeb60e502
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
  version "0.8.183"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.183/oversky-darwin-arm64"
      sha256 "a413755f72bb0a24a2cdf5bcfeb90c411cd7820c144eea4f91c182a8520f6711"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.183/oversky-darwin-x64"
      sha256 "6466d1d96fbdf1e526e740bf05aa8aad4e6847560fd214efb0c4223fe86f0274"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.183/oversky-linux-arm64"
      sha256 "8723d4371ad95fbfe9a9daeb496f84fac4c10a72413f371087ea3e7aeb60e502"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.183/oversky-linux-x64"
      sha256 "da99d26bb1fb0cbabd999a7e300c96ca95fecee1b7c2aa412c9362c2d07f5e0d"
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
