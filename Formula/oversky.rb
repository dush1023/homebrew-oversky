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
#   0.8.82                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.82/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   6dc213ee669c9bf4da4a08f0067928a19f7637f794b39d1bf7bb8aaf0b7a6a68       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.82/oversky-darwin-x64, 9956cd3ec045085162acbcbe37629e63ddf63eba43f0070cbb237bf9a130568b
#   https://updates.skrr.ai/daemon/releases/0.8.82/oversky-linux-x64,  ffb62c2438ebd59c53eb752b82344eade11bb2a40c3d7cce87cb4baaea397e0f
#   https://updates.skrr.ai/daemon/releases/0.8.82/oversky-linux-arm64, 9dfef79dffedf14cde5742f2128eaede5ee4110ded0765f9b81011d6fcbfb819
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
  version "0.8.82"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.82/oversky-darwin-arm64"
      sha256 "6dc213ee669c9bf4da4a08f0067928a19f7637f794b39d1bf7bb8aaf0b7a6a68"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.82/oversky-darwin-x64"
      sha256 "9956cd3ec045085162acbcbe37629e63ddf63eba43f0070cbb237bf9a130568b"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.82/oversky-linux-arm64"
      sha256 "9dfef79dffedf14cde5742f2128eaede5ee4110ded0765f9b81011d6fcbfb819"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.82/oversky-linux-x64"
      sha256 "ffb62c2438ebd59c53eb752b82344eade11bb2a40c3d7cce87cb4baaea397e0f"
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
