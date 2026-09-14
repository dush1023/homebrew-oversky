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
#   0.8.32                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.32/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   2f6508c75857fc9838a5d70c57b8e450368773f0ccacd58c8a50b37ab4427973       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.32/oversky-darwin-x64, 02b359cb02ed3b3b58d8db1f7163980eab90fde0189991dff4c79ca13b7cd016
#   https://updates.oversky.ai/daemon/releases/0.8.32/oversky-linux-x64,  1084870c7c31db1401d184ceddd9fd66c82a6b677539bc5afa7f16a3e92212c6
#   https://updates.oversky.ai/daemon/releases/0.8.32/oversky-linux-arm64, 6b52a299aeb537a392e7fae30ca2df5746e1f360a42f8eef511dfd36911f5062
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
  version "0.8.32"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.32/oversky-darwin-arm64"
      sha256 "2f6508c75857fc9838a5d70c57b8e450368773f0ccacd58c8a50b37ab4427973"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.32/oversky-darwin-x64"
      sha256 "02b359cb02ed3b3b58d8db1f7163980eab90fde0189991dff4c79ca13b7cd016"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.32/oversky-linux-arm64"
      sha256 "6b52a299aeb537a392e7fae30ca2df5746e1f360a42f8eef511dfd36911f5062"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.32/oversky-linux-x64"
      sha256 "1084870c7c31db1401d184ceddd9fd66c82a6b677539bc5afa7f16a3e92212c6"
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
