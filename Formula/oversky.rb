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
#   0.8.166                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.166/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   b6ccfa47c44f2c2514ba8e0a666ec9146de79506ff35c60cc376e28b6aae4570       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.166/oversky-darwin-x64, 8b4d5c2999bf38fa59b99a0ed1873b84363ba643b6356d768f599060d13f5abc
#   https://updates.skrr.ai/daemon/releases/0.8.166/oversky-linux-x64,  add0ef0188544f148adf4e29ab6f10401e96f786ab7f1708b2d50813258b990a
#   https://updates.skrr.ai/daemon/releases/0.8.166/oversky-linux-arm64, e85340354616b468dbb7b28a3ec1743949833f092ae94251019ec0d4608c9a2d
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
  version "0.8.166"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.166/oversky-darwin-arm64"
      sha256 "b6ccfa47c44f2c2514ba8e0a666ec9146de79506ff35c60cc376e28b6aae4570"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.166/oversky-darwin-x64"
      sha256 "8b4d5c2999bf38fa59b99a0ed1873b84363ba643b6356d768f599060d13f5abc"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.166/oversky-linux-arm64"
      sha256 "e85340354616b468dbb7b28a3ec1743949833f092ae94251019ec0d4608c9a2d"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.166/oversky-linux-x64"
      sha256 "add0ef0188544f148adf4e29ab6f10401e96f786ab7f1708b2d50813258b990a"
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
