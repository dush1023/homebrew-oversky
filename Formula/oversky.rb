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
#   0.8.174                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.174/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   4d1601dc2ec5f93ddf3d2f4646389682145d3df9af157ff3d3d4037ec44a8b54       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.174/oversky-darwin-x64, e73b7cc508878785f7b174793dac045fb5778e1610e75ea41e680700007c3a2b
#   https://updates.skrr.ai/daemon/releases/0.8.174/oversky-linux-x64,  e082131764c2bd647f27ad70125242c0733bab37312dc085c58998da876dfed6
#   https://updates.skrr.ai/daemon/releases/0.8.174/oversky-linux-arm64, 8ee9c83783eca9ca2c9132c912b6119dd2d8643cf416cb6ec8af98aa39807344
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
  version "0.8.174"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.174/oversky-darwin-arm64"
      sha256 "4d1601dc2ec5f93ddf3d2f4646389682145d3df9af157ff3d3d4037ec44a8b54"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.174/oversky-darwin-x64"
      sha256 "e73b7cc508878785f7b174793dac045fb5778e1610e75ea41e680700007c3a2b"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.174/oversky-linux-arm64"
      sha256 "8ee9c83783eca9ca2c9132c912b6119dd2d8643cf416cb6ec8af98aa39807344"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.174/oversky-linux-x64"
      sha256 "e082131764c2bd647f27ad70125242c0733bab37312dc085c58998da876dfed6"
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
