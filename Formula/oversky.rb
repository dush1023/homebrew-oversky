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
#   0.8.2                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.2/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   bfd93c6986a4eabac9ba19c9e7613867a6817f0d07a8604a545fb940ca0cbe95       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.2/oversky-darwin-x64, d91d0f3f739d25b875208f1d614046710e51e873272845b55b113ca0cb5853e6
#   https://updates.oversky.ai/daemon/releases/0.8.2/oversky-linux-x64,  b64f4b61d6509804aa2d2f5ab4e50319a98e7ce706af311ce0e3736029b1da42
#   https://updates.oversky.ai/daemon/releases/0.8.2/oversky-linux-arm64, 2bf5332c803f3c5082c0644e0a54be41e665f11f46444cd1d14066d115e0c110
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
  version "0.8.2"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.2/oversky-darwin-arm64"
      sha256 "bfd93c6986a4eabac9ba19c9e7613867a6817f0d07a8604a545fb940ca0cbe95"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.2/oversky-darwin-x64"
      sha256 "d91d0f3f739d25b875208f1d614046710e51e873272845b55b113ca0cb5853e6"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.2/oversky-linux-arm64"
      sha256 "2bf5332c803f3c5082c0644e0a54be41e665f11f46444cd1d14066d115e0c110"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.2/oversky-linux-x64"
      sha256 "b64f4b61d6509804aa2d2f5ab4e50319a98e7ce706af311ce0e3736029b1da42"
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
