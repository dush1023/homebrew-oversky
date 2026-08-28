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
#   0.8.6                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.6/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   5bba586c355b2bfff88b857f4e1608bb52279be39478f905d6aa33d29c8beb1d       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.6/oversky-darwin-x64, 4bba58213b5c548b9a4860ab25eaf03233b30b945450a247f009fa7a920695f4
#   https://updates.oversky.ai/daemon/releases/0.8.6/oversky-linux-x64,  ed01815b194d8a054ba6cbb7fab6cd9eec71a18c9d99c9731ddc885492799abd
#   https://updates.oversky.ai/daemon/releases/0.8.6/oversky-linux-arm64, 6cfb921748025d05335ec666bf3db4b93e10d63cd85d6e547bdab9a39f2053a1
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
  version "0.8.6"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.6/oversky-darwin-arm64"
      sha256 "5bba586c355b2bfff88b857f4e1608bb52279be39478f905d6aa33d29c8beb1d"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.6/oversky-darwin-x64"
      sha256 "4bba58213b5c548b9a4860ab25eaf03233b30b945450a247f009fa7a920695f4"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.6/oversky-linux-arm64"
      sha256 "6cfb921748025d05335ec666bf3db4b93e10d63cd85d6e547bdab9a39f2053a1"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.6/oversky-linux-x64"
      sha256 "ed01815b194d8a054ba6cbb7fab6cd9eec71a18c9d99c9731ddc885492799abd"
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
