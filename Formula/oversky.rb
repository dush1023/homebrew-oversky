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
#   0.8.197                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.197/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   572d4a764e68de4ae0a03d18df644a84cac20b8ec336e39cbc559fe41b8e9c82       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.197/oversky-darwin-x64, 64e9e02626a1b7a77d6b94d5f3f7594ff9460a52b50f5ebee7852a21eff2b3b4
#   https://updates.skrr.ai/daemon/releases/0.8.197/oversky-linux-x64,  d235e2e8ef21f4dd3c152a393363e2f90b39efd3fedac17732211224ddd525da
#   https://updates.skrr.ai/daemon/releases/0.8.197/oversky-linux-arm64, ff80d22ea74e3491527a8ffc620ed674458b05dba500967faf9d92fafd916211
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
  version "0.8.197"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.197/oversky-darwin-arm64"
      sha256 "572d4a764e68de4ae0a03d18df644a84cac20b8ec336e39cbc559fe41b8e9c82"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.197/oversky-darwin-x64"
      sha256 "64e9e02626a1b7a77d6b94d5f3f7594ff9460a52b50f5ebee7852a21eff2b3b4"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.197/oversky-linux-arm64"
      sha256 "ff80d22ea74e3491527a8ffc620ed674458b05dba500967faf9d92fafd916211"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.197/oversky-linux-x64"
      sha256 "d235e2e8ef21f4dd3c152a393363e2f90b39efd3fedac17732211224ddd525da"
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
