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
#   0.8.4                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.4/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   77673efa3c7dc4ce13fc17f1fc3187ea8b564226741fdb992f5a5542a22a2ea3       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.4/oversky-darwin-x64, cc58e17ebf81a5ed87f528070066e9d2c79e7919e575e22440a8a87e6f80c296
#   https://updates.oversky.ai/daemon/releases/0.8.4/oversky-linux-x64,  1d445ec762ddbe1e00d4c851040a75fa1b709b20d2c484d80dcb5b8378b19c6f
#   https://updates.oversky.ai/daemon/releases/0.8.4/oversky-linux-arm64, 346b0d6a6c9b7b58a25ac5094962b9f074aafc25bca34121e2b6a927742386bb
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
  version "0.8.4"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.4/oversky-darwin-arm64"
      sha256 "77673efa3c7dc4ce13fc17f1fc3187ea8b564226741fdb992f5a5542a22a2ea3"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.4/oversky-darwin-x64"
      sha256 "cc58e17ebf81a5ed87f528070066e9d2c79e7919e575e22440a8a87e6f80c296"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.4/oversky-linux-arm64"
      sha256 "346b0d6a6c9b7b58a25ac5094962b9f074aafc25bca34121e2b6a927742386bb"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.4/oversky-linux-x64"
      sha256 "1d445ec762ddbe1e00d4c851040a75fa1b709b20d2c484d80dcb5b8378b19c6f"
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
