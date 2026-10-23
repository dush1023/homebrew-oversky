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
#   0.8.130                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.130/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   af61e44e7a4dc79370431d039a72700fec82677ba55a4b038254e5ffabe4d0c6       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.130/oversky-darwin-x64, 97d3cfaa84e117791234c8e6ab3548e2253d1871dedbf72293bd069ab4aef24e
#   https://updates.skrr.ai/daemon/releases/0.8.130/oversky-linux-x64,  04ba3b83c5c1ffea373f20a65f424e211b3973f57730780640a44b47d20e9127
#   https://updates.skrr.ai/daemon/releases/0.8.130/oversky-linux-arm64, 579bff0d7b0bc52b062b18cfa0a65efb959cb52e5e6bde54ec4cad81efee8612
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
  version "0.8.130"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.130/oversky-darwin-arm64"
      sha256 "af61e44e7a4dc79370431d039a72700fec82677ba55a4b038254e5ffabe4d0c6"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.130/oversky-darwin-x64"
      sha256 "97d3cfaa84e117791234c8e6ab3548e2253d1871dedbf72293bd069ab4aef24e"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.130/oversky-linux-arm64"
      sha256 "579bff0d7b0bc52b062b18cfa0a65efb959cb52e5e6bde54ec4cad81efee8612"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.130/oversky-linux-x64"
      sha256 "04ba3b83c5c1ffea373f20a65f424e211b3973f57730780640a44b47d20e9127"
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
