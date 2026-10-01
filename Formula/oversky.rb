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
#   0.8.89                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.89/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   ddab9fbe6df63a7137dd9890243837936536ad23babe705d12cff22d348e8a5c       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.89/oversky-darwin-x64, f2156253a507c55c1798385e931ebcdb74af0a24ecd062ce038243e5ee1f594b
#   https://updates.skrr.ai/daemon/releases/0.8.89/oversky-linux-x64,  90e3185a5981ef7d78b6d7fca8f846cc3ea97532faf78a85adc1cb82245a8b0e
#   https://updates.skrr.ai/daemon/releases/0.8.89/oversky-linux-arm64, c582a76446e985659f58656ee88792f3a2d7394761c41884a609845db3c48265
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
  version "0.8.89"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.89/oversky-darwin-arm64"
      sha256 "ddab9fbe6df63a7137dd9890243837936536ad23babe705d12cff22d348e8a5c"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.89/oversky-darwin-x64"
      sha256 "f2156253a507c55c1798385e931ebcdb74af0a24ecd062ce038243e5ee1f594b"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.89/oversky-linux-arm64"
      sha256 "c582a76446e985659f58656ee88792f3a2d7394761c41884a609845db3c48265"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.89/oversky-linux-x64"
      sha256 "90e3185a5981ef7d78b6d7fca8f846cc3ea97532faf78a85adc1cb82245a8b0e"
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
