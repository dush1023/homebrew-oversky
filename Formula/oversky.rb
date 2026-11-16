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
#   0.8.165                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.165/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   31985e3d94bdf29cd580483ecf51f6d57ccf75f9ac6bbbee23598d33144155db       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.165/oversky-darwin-x64, a4ea687985086854a40792f5c4fb14917aa8fe01442913378fe27fc22e2d7cbf
#   https://updates.skrr.ai/daemon/releases/0.8.165/oversky-linux-x64,  f79306f045bb34b57e421862923d8d7503b7216f4d3526d8838350a7a89a2eb0
#   https://updates.skrr.ai/daemon/releases/0.8.165/oversky-linux-arm64, 379db32d976d493f17dafe71b45f337fe06c1a1d7b46c49e5e15a6d2e3828d7a
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
  version "0.8.165"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.165/oversky-darwin-arm64"
      sha256 "31985e3d94bdf29cd580483ecf51f6d57ccf75f9ac6bbbee23598d33144155db"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.165/oversky-darwin-x64"
      sha256 "a4ea687985086854a40792f5c4fb14917aa8fe01442913378fe27fc22e2d7cbf"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.165/oversky-linux-arm64"
      sha256 "379db32d976d493f17dafe71b45f337fe06c1a1d7b46c49e5e15a6d2e3828d7a"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.165/oversky-linux-x64"
      sha256 "f79306f045bb34b57e421862923d8d7503b7216f4d3526d8838350a7a89a2eb0"
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
