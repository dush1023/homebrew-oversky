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
#   0.8.114                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.114/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   c2f2c01d255af616ab09f1691fa73f03e509904382ce685a05943b9f9a4ff1e4       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.114/oversky-darwin-x64, 309ffe24269255eaa887e0036eaf3f470a01b94b7513f9049934974657c12de1
#   https://updates.skrr.ai/daemon/releases/0.8.114/oversky-linux-x64,  84c8fa4afdff315d4f070b607b876606309a5b1151a74730b9e08303b0227c9e
#   https://updates.skrr.ai/daemon/releases/0.8.114/oversky-linux-arm64, 7cfe2a5f496758f063e66ca0a24a3879ac04091b001b3eb69c54e07ed94d65ab
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
  version "0.8.114"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.114/oversky-darwin-arm64"
      sha256 "c2f2c01d255af616ab09f1691fa73f03e509904382ce685a05943b9f9a4ff1e4"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.114/oversky-darwin-x64"
      sha256 "309ffe24269255eaa887e0036eaf3f470a01b94b7513f9049934974657c12de1"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.114/oversky-linux-arm64"
      sha256 "7cfe2a5f496758f063e66ca0a24a3879ac04091b001b3eb69c54e07ed94d65ab"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.114/oversky-linux-x64"
      sha256 "84c8fa4afdff315d4f070b607b876606309a5b1151a74730b9e08303b0227c9e"
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
