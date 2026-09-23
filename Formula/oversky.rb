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
#   0.8.61                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.61/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   fb712c8a534c5ee2d6d80a7c5d86eca0571e09ae77e84d703d66da7c1b87ee26       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.61/oversky-darwin-x64, 5d6b7fb23b7cbb7c0f9807e3c53406afa2ddf7a0aa75942d04f30af0bd815f37
#   https://updates.skrr.ai/daemon/releases/0.8.61/oversky-linux-x64,  0690a288dd1772a0ad88d4b1a0091549a3ced8a1fc9ba3af4c14c8a04ebee9a3
#   https://updates.skrr.ai/daemon/releases/0.8.61/oversky-linux-arm64, 41051de90f7c3381a690dcb59bce11f3801853d5859e3bf415b4387962d39a28
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
  version "0.8.61"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.61/oversky-darwin-arm64"
      sha256 "fb712c8a534c5ee2d6d80a7c5d86eca0571e09ae77e84d703d66da7c1b87ee26"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.61/oversky-darwin-x64"
      sha256 "5d6b7fb23b7cbb7c0f9807e3c53406afa2ddf7a0aa75942d04f30af0bd815f37"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.61/oversky-linux-arm64"
      sha256 "41051de90f7c3381a690dcb59bce11f3801853d5859e3bf415b4387962d39a28"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.61/oversky-linux-x64"
      sha256 "0690a288dd1772a0ad88d4b1a0091549a3ced8a1fc9ba3af4c14c8a04ebee9a3"
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
