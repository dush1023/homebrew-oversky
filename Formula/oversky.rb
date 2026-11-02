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
#   0.8.138                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.138/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   386412c7edd4d8371c0a8e2939471351565d5330b768bd0b52d60e66eadbb03b       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.138/oversky-darwin-x64, dd334b4b730386bfb0cf4a8ede6194b82b5aa54f7d2b3fcd30c045a08e9b9bd9
#   https://updates.skrr.ai/daemon/releases/0.8.138/oversky-linux-x64,  59c0f22f5368b2285940a0f1d95fbf198cd6aaf1c0554011361e6cb1c6c744b3
#   https://updates.skrr.ai/daemon/releases/0.8.138/oversky-linux-arm64, 285d61dd0daf076c988b1c899628a0feaccddab7d689ea0dd04dd7201877a4fd
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
  version "0.8.138"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.138/oversky-darwin-arm64"
      sha256 "386412c7edd4d8371c0a8e2939471351565d5330b768bd0b52d60e66eadbb03b"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.138/oversky-darwin-x64"
      sha256 "dd334b4b730386bfb0cf4a8ede6194b82b5aa54f7d2b3fcd30c045a08e9b9bd9"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.138/oversky-linux-arm64"
      sha256 "285d61dd0daf076c988b1c899628a0feaccddab7d689ea0dd04dd7201877a4fd"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.138/oversky-linux-x64"
      sha256 "59c0f22f5368b2285940a0f1d95fbf198cd6aaf1c0554011361e6cb1c6c744b3"
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
