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
#   0.8.11                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.11/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   38b73567dee7bbe47190d05a72aabc5b608a8ef3c789795b6ba1af03e3cd4663       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.11/oversky-darwin-x64, 725dde9a905ca10c06aef37bea99aca8a6c86e4e27a636085187c5c4672f42dd
#   https://updates.oversky.ai/daemon/releases/0.8.11/oversky-linux-x64,  74958d3e0ed3d45adff555463a1f454a68de7d272b8fea78b797b49dba95baf4
#   https://updates.oversky.ai/daemon/releases/0.8.11/oversky-linux-arm64, 90e8664c2bff33465a99ccadecc791b9b421f1e9707c57714f4aa95bdda56348
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
  version "0.8.11"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.11/oversky-darwin-arm64"
      sha256 "38b73567dee7bbe47190d05a72aabc5b608a8ef3c789795b6ba1af03e3cd4663"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.11/oversky-darwin-x64"
      sha256 "725dde9a905ca10c06aef37bea99aca8a6c86e4e27a636085187c5c4672f42dd"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.11/oversky-linux-arm64"
      sha256 "90e8664c2bff33465a99ccadecc791b9b421f1e9707c57714f4aa95bdda56348"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.11/oversky-linux-x64"
      sha256 "74958d3e0ed3d45adff555463a1f454a68de7d272b8fea78b797b49dba95baf4"
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
