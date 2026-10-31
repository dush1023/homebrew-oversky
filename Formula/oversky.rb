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
#   0.8.136                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.136/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   d065f371204c0b5007343f14c4c094d52670cf79a273a2df4c334cdddb246b65       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.136/oversky-darwin-x64, b59931dafd90e2db0f50ed047bb1242f9872e1422be52f63c53828180906cf86
#   https://updates.skrr.ai/daemon/releases/0.8.136/oversky-linux-x64,  1c87fc4e51548ccf7f7fb6e7e62b433eeed484bab7b46042a4d18980b7d1eef8
#   https://updates.skrr.ai/daemon/releases/0.8.136/oversky-linux-arm64, ea18fabf8a6932ac06c662ae776008a4c7db3b1d6961844a9f6ce56156cc670b
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
  version "0.8.136"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.136/oversky-darwin-arm64"
      sha256 "d065f371204c0b5007343f14c4c094d52670cf79a273a2df4c334cdddb246b65"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.136/oversky-darwin-x64"
      sha256 "b59931dafd90e2db0f50ed047bb1242f9872e1422be52f63c53828180906cf86"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.136/oversky-linux-arm64"
      sha256 "ea18fabf8a6932ac06c662ae776008a4c7db3b1d6961844a9f6ce56156cc670b"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.136/oversky-linux-x64"
      sha256 "1c87fc4e51548ccf7f7fb6e7e62b433eeed484bab7b46042a4d18980b7d1eef8"
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
