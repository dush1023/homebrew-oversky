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
#   0.8.158                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.158/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   0f85e18e87099447b038e1191b56097e8d9783d0e92fddc92bbb5ffb4df33dc5       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.158/oversky-darwin-x64, 5ed3828b1ab8a7b042d6698715d4926816bc3365d2d1102a07413541ebbaa664
#   https://updates.skrr.ai/daemon/releases/0.8.158/oversky-linux-x64,  d42c8e08dd963361337a9f3534f8e1e90a5372ab1515dc715c4f5be6b34ccc03
#   https://updates.skrr.ai/daemon/releases/0.8.158/oversky-linux-arm64, 5bc16f0c05c4641ddbd3198673de19ed5a0f8e8f681913415cdda7dfeba5d396
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
  version "0.8.158"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.158/oversky-darwin-arm64"
      sha256 "0f85e18e87099447b038e1191b56097e8d9783d0e92fddc92bbb5ffb4df33dc5"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.158/oversky-darwin-x64"
      sha256 "5ed3828b1ab8a7b042d6698715d4926816bc3365d2d1102a07413541ebbaa664"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.158/oversky-linux-arm64"
      sha256 "5bc16f0c05c4641ddbd3198673de19ed5a0f8e8f681913415cdda7dfeba5d396"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.158/oversky-linux-x64"
      sha256 "d42c8e08dd963361337a9f3534f8e1e90a5372ab1515dc715c4f5be6b34ccc03"
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
