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
#   0.8.107                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.107/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   7ea803d391ff4733c11fe81a189ccbc7649f66a16181a20d446b4c49ea89a9a4       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.107/oversky-darwin-x64, 2de20c6b5ba0267aafc6e5fa8f7df45df05ec09f913d743cba4965c10c0583aa
#   https://updates.skrr.ai/daemon/releases/0.8.107/oversky-linux-x64,  78622a6bee84eb95016b0670c88d82832456b44d520aaa6e5a75ea9f07fe958a
#   https://updates.skrr.ai/daemon/releases/0.8.107/oversky-linux-arm64, 38300feb3a58a308f69557e2b7727f61e2dad5a5a3289479aa5f9be380fa6161
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
  version "0.8.107"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.107/oversky-darwin-arm64"
      sha256 "7ea803d391ff4733c11fe81a189ccbc7649f66a16181a20d446b4c49ea89a9a4"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.107/oversky-darwin-x64"
      sha256 "2de20c6b5ba0267aafc6e5fa8f7df45df05ec09f913d743cba4965c10c0583aa"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.107/oversky-linux-arm64"
      sha256 "38300feb3a58a308f69557e2b7727f61e2dad5a5a3289479aa5f9be380fa6161"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.107/oversky-linux-x64"
      sha256 "78622a6bee84eb95016b0670c88d82832456b44d520aaa6e5a75ea9f07fe958a"
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
