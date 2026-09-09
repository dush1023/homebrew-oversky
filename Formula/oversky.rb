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
#   0.8.19                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.19/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   33f23844a69510dd158ba962fde6512257042a50208ad1220eb7cc00001ee927       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.19/oversky-darwin-x64, fde5b7120763d2324965b6934fd7e7183fa8001127a0fb73dff5658a7e288624
#   https://updates.oversky.ai/daemon/releases/0.8.19/oversky-linux-x64,  d9b3e96dc0a88c23ed69f8199b889816a8f3ffda9df92f7f48fb4ecdd46b3653
#   https://updates.oversky.ai/daemon/releases/0.8.19/oversky-linux-arm64, f06274fc1a06240ec9719802d504bba968e2881d37b0be68bfdeeac432464133
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
  version "0.8.19"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.19/oversky-darwin-arm64"
      sha256 "33f23844a69510dd158ba962fde6512257042a50208ad1220eb7cc00001ee927"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.19/oversky-darwin-x64"
      sha256 "fde5b7120763d2324965b6934fd7e7183fa8001127a0fb73dff5658a7e288624"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.19/oversky-linux-arm64"
      sha256 "f06274fc1a06240ec9719802d504bba968e2881d37b0be68bfdeeac432464133"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.19/oversky-linux-x64"
      sha256 "d9b3e96dc0a88c23ed69f8199b889816a8f3ffda9df92f7f48fb4ecdd46b3653"
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
