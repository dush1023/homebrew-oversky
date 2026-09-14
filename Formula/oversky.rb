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
#   0.8.37                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.37/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   b1549aba9b1a15ed794747b320c4218bf7189f69cbf4e15d4f4e08add080d057       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.37/oversky-darwin-x64, da6dee86272af1a1b472e730e901a57160a3afa25dfc11812b1818d13aab39fd
#   https://updates.oversky.ai/daemon/releases/0.8.37/oversky-linux-x64,  d40053c05f6027587a5a7c57cf2f9f571b90282a708acc62c3c49a9ac83c4d52
#   https://updates.oversky.ai/daemon/releases/0.8.37/oversky-linux-arm64, 91c6f22c259c5398cdc5db7b24a6b268a94e148ce67617f0357ffa475694fa59
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
  version "0.8.37"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.37/oversky-darwin-arm64"
      sha256 "b1549aba9b1a15ed794747b320c4218bf7189f69cbf4e15d4f4e08add080d057"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.37/oversky-darwin-x64"
      sha256 "da6dee86272af1a1b472e730e901a57160a3afa25dfc11812b1818d13aab39fd"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.37/oversky-linux-arm64"
      sha256 "91c6f22c259c5398cdc5db7b24a6b268a94e148ce67617f0357ffa475694fa59"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.37/oversky-linux-x64"
      sha256 "d40053c05f6027587a5a7c57cf2f9f571b90282a708acc62c3c49a9ac83c4d52"
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
