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
#   0.8.25                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.25/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   a035efb0525128f0421bd0f0ef892156b72a92bbfeae33c8bfec69fdb549f473       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.25/oversky-darwin-x64, b0be8f1eec9516a6789bd03c93aae7cd40a1066639d5cb7699e0cd636866d5ba
#   https://updates.oversky.ai/daemon/releases/0.8.25/oversky-linux-x64,  be91ef0b8c6d2320f926654b4e8a5ac8f476f13b6b1b2b9237df59d732675544
#   https://updates.oversky.ai/daemon/releases/0.8.25/oversky-linux-arm64, 422563a5522497d48e114d2b3b9fe3a6ffb7786ae10ab1e80368c74e56a79f27
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
  version "0.8.25"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.25/oversky-darwin-arm64"
      sha256 "a035efb0525128f0421bd0f0ef892156b72a92bbfeae33c8bfec69fdb549f473"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.25/oversky-darwin-x64"
      sha256 "b0be8f1eec9516a6789bd03c93aae7cd40a1066639d5cb7699e0cd636866d5ba"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.25/oversky-linux-arm64"
      sha256 "422563a5522497d48e114d2b3b9fe3a6ffb7786ae10ab1e80368c74e56a79f27"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.25/oversky-linux-x64"
      sha256 "be91ef0b8c6d2320f926654b4e8a5ac8f476f13b6b1b2b9237df59d732675544"
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
