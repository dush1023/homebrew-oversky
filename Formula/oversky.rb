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
#   0.8.202                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.202/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   b2aca9728ac3a405a1d744c86a5188cbe61a976f572c67ea5623552e343f72ae       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.202/oversky-darwin-x64, a86cba6a2a5daff7d59470dfb81dc5b40f4e0e2f34e645c1a607381e3e11390c
#   https://updates.skrr.ai/daemon/releases/0.8.202/oversky-linux-x64,  fd9357b82bb8a802f713abc42ccc308b04edf83861e6d7ac8550f51f616d8ff1
#   https://updates.skrr.ai/daemon/releases/0.8.202/oversky-linux-arm64, 2d0d41ed0e6594654c4422c3a342ddcc61075791fbb092082400909cb2fd2a6e
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
  version "0.8.202"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.202/oversky-darwin-arm64"
      sha256 "b2aca9728ac3a405a1d744c86a5188cbe61a976f572c67ea5623552e343f72ae"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.202/oversky-darwin-x64"
      sha256 "a86cba6a2a5daff7d59470dfb81dc5b40f4e0e2f34e645c1a607381e3e11390c"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.202/oversky-linux-arm64"
      sha256 "2d0d41ed0e6594654c4422c3a342ddcc61075791fbb092082400909cb2fd2a6e"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.202/oversky-linux-x64"
      sha256 "fd9357b82bb8a802f713abc42ccc308b04edf83861e6d7ac8550f51f616d8ff1"
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
