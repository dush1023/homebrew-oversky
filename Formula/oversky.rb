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
#   0.8.184                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.184/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   1c411319dd4395faf8b2bfdc32b0a60cbee0fad2f1d8e4dc3495eb7166b0e138       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.184/oversky-darwin-x64, 3396aae6dd679370b91e6cce66ab4c90cef69145325556f27ba3f6054ef9033c
#   https://updates.skrr.ai/daemon/releases/0.8.184/oversky-linux-x64,  6ce1a04ec4a39509e8cf75145e1dffae37d690721e3cb86e4c8893b0db7f0caf
#   https://updates.skrr.ai/daemon/releases/0.8.184/oversky-linux-arm64, 01bfb33fe276af5fb024652b7930644bb787a01b92030a4b17650b8b8d09bc6b
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
  version "0.8.184"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.184/oversky-darwin-arm64"
      sha256 "1c411319dd4395faf8b2bfdc32b0a60cbee0fad2f1d8e4dc3495eb7166b0e138"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.184/oversky-darwin-x64"
      sha256 "3396aae6dd679370b91e6cce66ab4c90cef69145325556f27ba3f6054ef9033c"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.184/oversky-linux-arm64"
      sha256 "01bfb33fe276af5fb024652b7930644bb787a01b92030a4b17650b8b8d09bc6b"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.184/oversky-linux-x64"
      sha256 "6ce1a04ec4a39509e8cf75145e1dffae37d690721e3cb86e4c8893b0db7f0caf"
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
