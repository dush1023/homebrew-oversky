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
#   0.8.46                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.46/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   c0b1e42337b8386385d510fb4fce8ebcfdedf34cd9227a4079d3de54db89fe21       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.46/oversky-darwin-x64, a83691eea29e1a9528b1678de96c694c978e541d8a1ba1425d3d102683a1de9c
#   https://updates.oversky.ai/daemon/releases/0.8.46/oversky-linux-x64,  08556832bd4cf0ab3fe0e89654858da125dc84e0b2bf63e541a3f0f03097b8d3
#   https://updates.oversky.ai/daemon/releases/0.8.46/oversky-linux-arm64, 07c44387b8f6f0bcea09b32d7e488f48ce72ae3fb53bfea9645c58f66288f720
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
  version "0.8.46"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.46/oversky-darwin-arm64"
      sha256 "c0b1e42337b8386385d510fb4fce8ebcfdedf34cd9227a4079d3de54db89fe21"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.46/oversky-darwin-x64"
      sha256 "a83691eea29e1a9528b1678de96c694c978e541d8a1ba1425d3d102683a1de9c"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.46/oversky-linux-arm64"
      sha256 "07c44387b8f6f0bcea09b32d7e488f48ce72ae3fb53bfea9645c58f66288f720"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.46/oversky-linux-x64"
      sha256 "08556832bd4cf0ab3fe0e89654858da125dc84e0b2bf63e541a3f0f03097b8d3"
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
