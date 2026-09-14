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
#   0.8.33                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.33/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   03aec53f567f9385a64641bf7bc668528e87ccb99cd38fd6b07e584d67241b74       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.33/oversky-darwin-x64, 86934e871495e399a9a0c37dfe814b6ce05619cf8a893cee0673c7703ef28003
#   https://updates.oversky.ai/daemon/releases/0.8.33/oversky-linux-x64,  35a8630eefb0204aff1e7f94864be3585b8810ae388be738b3297cdedfcf7dc4
#   https://updates.oversky.ai/daemon/releases/0.8.33/oversky-linux-arm64, 3b702fb332b5f4d5d274496fcb2015c21e650bf88a0e1f4dc7bd610679b6c7ce
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
  version "0.8.33"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.33/oversky-darwin-arm64"
      sha256 "03aec53f567f9385a64641bf7bc668528e87ccb99cd38fd6b07e584d67241b74"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.33/oversky-darwin-x64"
      sha256 "86934e871495e399a9a0c37dfe814b6ce05619cf8a893cee0673c7703ef28003"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.33/oversky-linux-arm64"
      sha256 "3b702fb332b5f4d5d274496fcb2015c21e650bf88a0e1f4dc7bd610679b6c7ce"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.33/oversky-linux-x64"
      sha256 "35a8630eefb0204aff1e7f94864be3585b8810ae388be738b3297cdedfcf7dc4"
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
