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
#   0.8.1                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.1/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   38659c2979608b8e93d44b18ebbdd6b2ba99505b9c8372a1173db3c29cb47efd       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.1/oversky-darwin-x64, dcad5c55599acf561e5f853cef400b6e24ff9aae8ee0beaa60fc191e9e012bcb
#   https://updates.oversky.ai/daemon/releases/0.8.1/oversky-linux-x64,  6142e5d060e6b9be8061730181886165a656de78fef15287d977d66a9134a4ea
#   https://updates.oversky.ai/daemon/releases/0.8.1/oversky-linux-arm64, edd936b96c2a61265ba52ba781f6ba95792e306a12e88742825b278bbb041c93
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
  version "0.8.1"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.1/oversky-darwin-arm64"
      sha256 "38659c2979608b8e93d44b18ebbdd6b2ba99505b9c8372a1173db3c29cb47efd"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.1/oversky-darwin-x64"
      sha256 "dcad5c55599acf561e5f853cef400b6e24ff9aae8ee0beaa60fc191e9e012bcb"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.1/oversky-linux-arm64"
      sha256 "edd936b96c2a61265ba52ba781f6ba95792e306a12e88742825b278bbb041c93"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.1/oversky-linux-x64"
      sha256 "6142e5d060e6b9be8061730181886165a656de78fef15287d977d66a9134a4ea"
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
