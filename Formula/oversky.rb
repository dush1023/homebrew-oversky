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
#   https://updates.oversky.ai/daemon/releases/<version>
# and each URL resolves to <BASE>/oversky-<platform>-<arch>. Keep that BASE in
# lockstep with scripts/install-daemon.sh's download base.
#
# Placeholders (all single-quoted so shell interpolation can't clash):
#   0.8.31                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.31/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   f52be2d4ee92b4f1a64f62a78ba478809ff14672c5c1afb0387ecb0fb5bef587       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.31/oversky-darwin-x64, 330c88484863ffdb447bee9d5e06414b78983ae4f28fa197aeea9ab63de5ec32
#   https://updates.oversky.ai/daemon/releases/0.8.31/oversky-linux-x64,  313ad24875764c5ae082e33b77388b46ba96d983822d98b60f09b99862bf5dc4
#   https://updates.oversky.ai/daemon/releases/0.8.31/oversky-linux-arm64, 65ba0ffed98c677bd5216d14734cc1405faf61c6d7b15fc36edab7d18cbc877f
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
  version "0.8.31"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.31/oversky-darwin-arm64"
      sha256 "f52be2d4ee92b4f1a64f62a78ba478809ff14672c5c1afb0387ecb0fb5bef587"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.31/oversky-darwin-x64"
      sha256 "330c88484863ffdb447bee9d5e06414b78983ae4f28fa197aeea9ab63de5ec32"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.31/oversky-linux-arm64"
      sha256 "65ba0ffed98c677bd5216d14734cc1405faf61c6d7b15fc36edab7d18cbc877f"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.31/oversky-linux-x64"
      sha256 "313ad24875764c5ae082e33b77388b46ba96d983822d98b60f09b99862bf5dc4"
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
