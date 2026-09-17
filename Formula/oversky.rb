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
#   0.8.49                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.49/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   57af5e4d337d02831879d67073610f9c4f367356f1893a473f3f43e74d3f7c1e       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.49/oversky-darwin-x64, 4732190fbf4c7b338e12a94873351c14bc05e77317110d456dae691c91e9b3fe
#   https://updates.oversky.ai/daemon/releases/0.8.49/oversky-linux-x64,  538291c0471d68105f8ab00b12b8cfb9e71c3575af457ac0315574dbd147feda
#   https://updates.oversky.ai/daemon/releases/0.8.49/oversky-linux-arm64, 6f6798cccc834247f9ebc2eafa19af71c1206ac57aae00631e61e34c79fb8a4d
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
  version "0.8.49"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.49/oversky-darwin-arm64"
      sha256 "57af5e4d337d02831879d67073610f9c4f367356f1893a473f3f43e74d3f7c1e"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.49/oversky-darwin-x64"
      sha256 "4732190fbf4c7b338e12a94873351c14bc05e77317110d456dae691c91e9b3fe"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.49/oversky-linux-arm64"
      sha256 "6f6798cccc834247f9ebc2eafa19af71c1206ac57aae00631e61e34c79fb8a4d"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.49/oversky-linux-x64"
      sha256 "538291c0471d68105f8ab00b12b8cfb9e71c3575af457ac0315574dbd147feda"
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
