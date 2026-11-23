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
#   0.8.187                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.187/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   5c1eb9a368e506d026734ba5e959330e82ba12748a7c3cd60a1a251fa983f83f       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.187/oversky-darwin-x64, d12db4da1c7b56c408bdca6b2dc1607ff46b3738f57b83dc23c61a56b77a6f43
#   https://updates.skrr.ai/daemon/releases/0.8.187/oversky-linux-x64,  bf74a9c0844716a8ad040d8559200a83da4e396fdd320c1881e8c9b30b90ad10
#   https://updates.skrr.ai/daemon/releases/0.8.187/oversky-linux-arm64, 348b0bdbec6ae025971fc8b80c8c03cff60bf8605a8092e62938d0b74df83748
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
  version "0.8.187"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.187/oversky-darwin-arm64"
      sha256 "5c1eb9a368e506d026734ba5e959330e82ba12748a7c3cd60a1a251fa983f83f"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.187/oversky-darwin-x64"
      sha256 "d12db4da1c7b56c408bdca6b2dc1607ff46b3738f57b83dc23c61a56b77a6f43"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.187/oversky-linux-arm64"
      sha256 "348b0bdbec6ae025971fc8b80c8c03cff60bf8605a8092e62938d0b74df83748"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.187/oversky-linux-x64"
      sha256 "bf74a9c0844716a8ad040d8559200a83da4e396fdd320c1881e8c9b30b90ad10"
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
