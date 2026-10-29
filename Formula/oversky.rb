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
#   0.8.132                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.132/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   632a167b4967c95e268887f0296f1260e8835855e88e661710249cd22c783649       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.132/oversky-darwin-x64, 3a0de24fd679f46a12cec6183e701bb3eaebed0d719fd0a90e66bfee41683387
#   https://updates.skrr.ai/daemon/releases/0.8.132/oversky-linux-x64,  98dc148ac8d3ae3d32c8ffa3bb24b7602924fcac435e394d249f9c70d814426e
#   https://updates.skrr.ai/daemon/releases/0.8.132/oversky-linux-arm64, a40691bafc7ee292131e7994ae6887f459a712b9a508627a2889bb737da91ed4
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
  version "0.8.132"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.132/oversky-darwin-arm64"
      sha256 "632a167b4967c95e268887f0296f1260e8835855e88e661710249cd22c783649"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.132/oversky-darwin-x64"
      sha256 "3a0de24fd679f46a12cec6183e701bb3eaebed0d719fd0a90e66bfee41683387"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.132/oversky-linux-arm64"
      sha256 "a40691bafc7ee292131e7994ae6887f459a712b9a508627a2889bb737da91ed4"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.132/oversky-linux-x64"
      sha256 "98dc148ac8d3ae3d32c8ffa3bb24b7602924fcac435e394d249f9c70d814426e"
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
