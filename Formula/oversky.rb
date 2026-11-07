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
#   0.8.153                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.153/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   cad878b44b5b2041a758d378ebb42ea3633333d5e49c23bba52ea180f0147688       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.153/oversky-darwin-x64, aba4eb6de3e4ed9c9796f2d6aedc5ce22c32fc755665d4d4fe08130604b0af68
#   https://updates.skrr.ai/daemon/releases/0.8.153/oversky-linux-x64,  28570cc89fbdcc7cfeaa5b72564c48c8d2b31d3f603a817fa59910bd4e774268
#   https://updates.skrr.ai/daemon/releases/0.8.153/oversky-linux-arm64, 2311f06e06c97983dfbf9f96283ab33feea20e739533def782d73dec644ab594
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
  version "0.8.153"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.153/oversky-darwin-arm64"
      sha256 "cad878b44b5b2041a758d378ebb42ea3633333d5e49c23bba52ea180f0147688"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.153/oversky-darwin-x64"
      sha256 "aba4eb6de3e4ed9c9796f2d6aedc5ce22c32fc755665d4d4fe08130604b0af68"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.153/oversky-linux-arm64"
      sha256 "2311f06e06c97983dfbf9f96283ab33feea20e739533def782d73dec644ab594"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.153/oversky-linux-x64"
      sha256 "28570cc89fbdcc7cfeaa5b72564c48c8d2b31d3f603a817fa59910bd4e774268"
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
