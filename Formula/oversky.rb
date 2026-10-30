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
#   0.8.133                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.133/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   d82f590403da12c6c5e47da6f7e3cf32652ff56f8d38d9a99c91508f33430d1e       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.133/oversky-darwin-x64, e0f510ee771edfffd03e49aa12578706469d103ffbd440242600929a9b882e53
#   https://updates.skrr.ai/daemon/releases/0.8.133/oversky-linux-x64,  68ad760d2da37d38a0c9ca1e23b21ccb4728ca4aa69a2f6f9338673c5fc8a6e9
#   https://updates.skrr.ai/daemon/releases/0.8.133/oversky-linux-arm64, 0d07f0989a7c3c22e535988923366d92184da4b10f4102ed3c2bcfe989319d6f
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
  version "0.8.133"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.133/oversky-darwin-arm64"
      sha256 "d82f590403da12c6c5e47da6f7e3cf32652ff56f8d38d9a99c91508f33430d1e"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.133/oversky-darwin-x64"
      sha256 "e0f510ee771edfffd03e49aa12578706469d103ffbd440242600929a9b882e53"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.133/oversky-linux-arm64"
      sha256 "0d07f0989a7c3c22e535988923366d92184da4b10f4102ed3c2bcfe989319d6f"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.133/oversky-linux-x64"
      sha256 "68ad760d2da37d38a0c9ca1e23b21ccb4728ca4aa69a2f6f9338673c5fc8a6e9"
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
