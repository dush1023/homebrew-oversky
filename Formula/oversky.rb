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
#   0.8.57                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.57/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   62d5469899ed335097b13813fc1f99951876855140ee6971032de18cec1c49d1       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.57/oversky-darwin-x64, 2c8cb67212bff55f8e4dca9d591de4df355fe2d460362712a36b24402df696e2
#   https://updates.oversky.ai/daemon/releases/0.8.57/oversky-linux-x64,  b5f5e3147c425e9dadff1a0796e8d2e3d3810495259ea9d39d1518457883dc1d
#   https://updates.oversky.ai/daemon/releases/0.8.57/oversky-linux-arm64, 2bb6c1ead7c1e5287f190aa2d2475d4f39c25b5aa75522d586f9cafc8ad1ba92
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
  version "0.8.57"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.57/oversky-darwin-arm64"
      sha256 "62d5469899ed335097b13813fc1f99951876855140ee6971032de18cec1c49d1"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.57/oversky-darwin-x64"
      sha256 "2c8cb67212bff55f8e4dca9d591de4df355fe2d460362712a36b24402df696e2"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.57/oversky-linux-arm64"
      sha256 "2bb6c1ead7c1e5287f190aa2d2475d4f39c25b5aa75522d586f9cafc8ad1ba92"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.57/oversky-linux-x64"
      sha256 "b5f5e3147c425e9dadff1a0796e8d2e3d3810495259ea9d39d1518457883dc1d"
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
