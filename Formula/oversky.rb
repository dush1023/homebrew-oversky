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
#   0.8.59                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.59/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   578fe7d36f0b0f47e12da992785efc2768ef710f07a1049890afc8f4430febf4       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.59/oversky-darwin-x64, b299d2cf7f096af75511529b2fbd07b7bcb2b07222af1edcaea0cdb6a8eb54af
#   https://updates.oversky.ai/daemon/releases/0.8.59/oversky-linux-x64,  d2d58921f91f1bdd3cc7f3c22dd9ff4de4c3eb7c2e0181598ded8c557c543fda
#   https://updates.oversky.ai/daemon/releases/0.8.59/oversky-linux-arm64, 4d7debf5771d66a29f52768feebc0bfaccdc204a35525e8755d0275796d1f391
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
  version "0.8.59"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.59/oversky-darwin-arm64"
      sha256 "578fe7d36f0b0f47e12da992785efc2768ef710f07a1049890afc8f4430febf4"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.59/oversky-darwin-x64"
      sha256 "b299d2cf7f096af75511529b2fbd07b7bcb2b07222af1edcaea0cdb6a8eb54af"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.59/oversky-linux-arm64"
      sha256 "4d7debf5771d66a29f52768feebc0bfaccdc204a35525e8755d0275796d1f391"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.59/oversky-linux-x64"
      sha256 "d2d58921f91f1bdd3cc7f3c22dd9ff4de4c3eb7c2e0181598ded8c557c543fda"
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
