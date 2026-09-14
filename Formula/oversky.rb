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
#   0.8.38                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.38/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   38a35852794703b06163204d6a83dc6dbcad79ce251df6532f5d1643094af941       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.38/oversky-darwin-x64, 1f8d878d2d86d38fbc1fcafe0105fed41b3fc7d0813a7f5a1d4744185c05d82a
#   https://updates.oversky.ai/daemon/releases/0.8.38/oversky-linux-x64,  5efe116afbe38ba576bbdc3fa72d8399a41a60231f5a71fa21df91f55ac60da2
#   https://updates.oversky.ai/daemon/releases/0.8.38/oversky-linux-arm64, 9278e5fe607609a63ef0b3aa32b574383d25a7be05257209418efccdd35f124e
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
  version "0.8.38"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.38/oversky-darwin-arm64"
      sha256 "38a35852794703b06163204d6a83dc6dbcad79ce251df6532f5d1643094af941"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.38/oversky-darwin-x64"
      sha256 "1f8d878d2d86d38fbc1fcafe0105fed41b3fc7d0813a7f5a1d4744185c05d82a"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.38/oversky-linux-arm64"
      sha256 "9278e5fe607609a63ef0b3aa32b574383d25a7be05257209418efccdd35f124e"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.38/oversky-linux-x64"
      sha256 "5efe116afbe38ba576bbdc3fa72d8399a41a60231f5a71fa21df91f55ac60da2"
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
