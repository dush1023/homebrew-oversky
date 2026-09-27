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
#   0.8.70                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.70/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   4b09dfc0e247a74bd34611c40a920bf667b299e44623c2bac12baa7fb75e3483       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.70/oversky-darwin-x64, b99fd5922efa2c17fdb9bd8d95ba62fb66f06debf8cfb19575c285a1536c7851
#   https://updates.skrr.ai/daemon/releases/0.8.70/oversky-linux-x64,  4e0a5fa08bd5025afce280be299b7bd53c6b23110c3d78628693288a74e73ab4
#   https://updates.skrr.ai/daemon/releases/0.8.70/oversky-linux-arm64, f4a7b90625125567d09363cb5438f078ce9bd46bfc234380d26f04206845b442
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
  version "0.8.70"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.70/oversky-darwin-arm64"
      sha256 "4b09dfc0e247a74bd34611c40a920bf667b299e44623c2bac12baa7fb75e3483"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.70/oversky-darwin-x64"
      sha256 "b99fd5922efa2c17fdb9bd8d95ba62fb66f06debf8cfb19575c285a1536c7851"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.70/oversky-linux-arm64"
      sha256 "f4a7b90625125567d09363cb5438f078ce9bd46bfc234380d26f04206845b442"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.70/oversky-linux-x64"
      sha256 "4e0a5fa08bd5025afce280be299b7bd53c6b23110c3d78628693288a74e73ab4"
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
