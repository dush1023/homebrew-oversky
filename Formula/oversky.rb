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
#   0.8.41                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.41/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   e017bc02b583105f95f00567e348de5e7f71ca9232536fc7c9ffc2862e094d0f       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.41/oversky-darwin-x64, 884c8462dab75020b5f7b778baf0a9f968e09d03f3934e8aae6f7d39177ae2f6
#   https://updates.oversky.ai/daemon/releases/0.8.41/oversky-linux-x64,  e95c680d5e686c9ba0cb360e5f96eb801e5df94e80e7c7d9e80362bf7b585a0c
#   https://updates.oversky.ai/daemon/releases/0.8.41/oversky-linux-arm64, d3b32fcc4b7e5e21d4f091af3a5b9ecdad3d9c471e83cabc962d24bc55551212
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
  version "0.8.41"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.41/oversky-darwin-arm64"
      sha256 "e017bc02b583105f95f00567e348de5e7f71ca9232536fc7c9ffc2862e094d0f"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.41/oversky-darwin-x64"
      sha256 "884c8462dab75020b5f7b778baf0a9f968e09d03f3934e8aae6f7d39177ae2f6"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.41/oversky-linux-arm64"
      sha256 "d3b32fcc4b7e5e21d4f091af3a5b9ecdad3d9c471e83cabc962d24bc55551212"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.41/oversky-linux-x64"
      sha256 "e95c680d5e686c9ba0cb360e5f96eb801e5df94e80e7c7d9e80362bf7b585a0c"
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
