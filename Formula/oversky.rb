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
#   0.8.154                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.154/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   a9dce3d9fab48c65f3bf6cce9f0ae9c450691d070238e10f67dcbb3d2bd30fef       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.154/oversky-darwin-x64, 4fcfb3cc4b56194f2ae1a6112fc8d5ae158beb8938ec844731b0dc9370662d8d
#   https://updates.skrr.ai/daemon/releases/0.8.154/oversky-linux-x64,  4ff3d3a8ebdb71c4660298b8e9a9138b91ffdf992d3e7cc01f8b7c3bd64f5f81
#   https://updates.skrr.ai/daemon/releases/0.8.154/oversky-linux-arm64, 06ab991dee0f93dec7499431b0217671b03ff13ea6e9f0565f14fa0cbcfed8c6
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
  version "0.8.154"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.154/oversky-darwin-arm64"
      sha256 "a9dce3d9fab48c65f3bf6cce9f0ae9c450691d070238e10f67dcbb3d2bd30fef"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.154/oversky-darwin-x64"
      sha256 "4fcfb3cc4b56194f2ae1a6112fc8d5ae158beb8938ec844731b0dc9370662d8d"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.154/oversky-linux-arm64"
      sha256 "06ab991dee0f93dec7499431b0217671b03ff13ea6e9f0565f14fa0cbcfed8c6"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.154/oversky-linux-x64"
      sha256 "4ff3d3a8ebdb71c4660298b8e9a9138b91ffdf992d3e7cc01f8b7c3bd64f5f81"
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
