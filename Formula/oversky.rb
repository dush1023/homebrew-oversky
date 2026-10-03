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
#   0.8.97                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.97/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   e91392f09e17b99e05918a7ba16d24b0a6d2d657fdd4e26e5802ab5412001cdf       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.97/oversky-darwin-x64, 9cbe0d8debb2c1a85525b3fec7fa0b3c9b35964d0af7bedb7448806052c422f4
#   https://updates.skrr.ai/daemon/releases/0.8.97/oversky-linux-x64,  4e65d304ca78882f8017e1d213ec6b0274b20ffab20014950185184d5a38955b
#   https://updates.skrr.ai/daemon/releases/0.8.97/oversky-linux-arm64, 0b9236e0a3a1880e436c2aaed0b0150e20df4f227381a9c6da1f8b3a5dfc2778
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
  version "0.8.97"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.97/oversky-darwin-arm64"
      sha256 "e91392f09e17b99e05918a7ba16d24b0a6d2d657fdd4e26e5802ab5412001cdf"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.97/oversky-darwin-x64"
      sha256 "9cbe0d8debb2c1a85525b3fec7fa0b3c9b35964d0af7bedb7448806052c422f4"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.97/oversky-linux-arm64"
      sha256 "0b9236e0a3a1880e436c2aaed0b0150e20df4f227381a9c6da1f8b3a5dfc2778"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.97/oversky-linux-x64"
      sha256 "4e65d304ca78882f8017e1d213ec6b0274b20ffab20014950185184d5a38955b"
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
