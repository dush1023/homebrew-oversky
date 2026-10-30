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
#   0.8.134                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.134/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   4a0595a461190c038758399d25c892b020e494217f9208324e1ab2c4502ede3b       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.134/oversky-darwin-x64, 25173c6dd7045bf45c6097eb59ed5d5689d7e52a869867e4047fd967b1534540
#   https://updates.skrr.ai/daemon/releases/0.8.134/oversky-linux-x64,  4cec615581c2b7f6cd1e3ad7bbef1c0714244aeb4033deb3bde0b0212d41478f
#   https://updates.skrr.ai/daemon/releases/0.8.134/oversky-linux-arm64, d5ea74c3377ca66b760b0ffb30c17816b58e797187172c58f684cb1b37f9de2f
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
  version "0.8.134"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.134/oversky-darwin-arm64"
      sha256 "4a0595a461190c038758399d25c892b020e494217f9208324e1ab2c4502ede3b"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.134/oversky-darwin-x64"
      sha256 "25173c6dd7045bf45c6097eb59ed5d5689d7e52a869867e4047fd967b1534540"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.134/oversky-linux-arm64"
      sha256 "d5ea74c3377ca66b760b0ffb30c17816b58e797187172c58f684cb1b37f9de2f"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.134/oversky-linux-x64"
      sha256 "4cec615581c2b7f6cd1e3ad7bbef1c0714244aeb4033deb3bde0b0212d41478f"
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
