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
#   0.8.42                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.42/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   7566af7bc6f682a697f0deb55c3b8e367a3e703fd4d2d96550dd3b1e8ac965ed       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.42/oversky-darwin-x64, 5b983b45f5cf477480251da73317e08eea38e616928dad51650a4fa31632494a
#   https://updates.oversky.ai/daemon/releases/0.8.42/oversky-linux-x64,  3e0a74ed3553465c3d400e456e5a4b13eb4f0bc2be28ab71e1c70fb85a5c77aa
#   https://updates.oversky.ai/daemon/releases/0.8.42/oversky-linux-arm64, 784d5c42cc7713d76df2cf8d9d67bb07d3ab2f6721a12d28aeaf1e0334ebdd77
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
  version "0.8.42"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.42/oversky-darwin-arm64"
      sha256 "7566af7bc6f682a697f0deb55c3b8e367a3e703fd4d2d96550dd3b1e8ac965ed"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.42/oversky-darwin-x64"
      sha256 "5b983b45f5cf477480251da73317e08eea38e616928dad51650a4fa31632494a"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.42/oversky-linux-arm64"
      sha256 "784d5c42cc7713d76df2cf8d9d67bb07d3ab2f6721a12d28aeaf1e0334ebdd77"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.42/oversky-linux-x64"
      sha256 "3e0a74ed3553465c3d400e456e5a4b13eb4f0bc2be28ab71e1c70fb85a5c77aa"
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
