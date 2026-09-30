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
#   0.8.80                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.80/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   674a0bfd0c2adb47552189986c957545ee92d487edaf2a72f03798638314ab75       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.80/oversky-darwin-x64, 94f5cbae221d3e599fbe620a7c98a524c02557224cf488b719eaab8cabc979cb
#   https://updates.skrr.ai/daemon/releases/0.8.80/oversky-linux-x64,  96b557a3cde78a2b208524cf215dbe16a83f4215e3e118d78323d5d3a82e1548
#   https://updates.skrr.ai/daemon/releases/0.8.80/oversky-linux-arm64, 744061a6fd42ae9160791bf1474dfecc121a08a4b8d2fb3ec247a4e251428134
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
  version "0.8.80"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.80/oversky-darwin-arm64"
      sha256 "674a0bfd0c2adb47552189986c957545ee92d487edaf2a72f03798638314ab75"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.80/oversky-darwin-x64"
      sha256 "94f5cbae221d3e599fbe620a7c98a524c02557224cf488b719eaab8cabc979cb"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.80/oversky-linux-arm64"
      sha256 "744061a6fd42ae9160791bf1474dfecc121a08a4b8d2fb3ec247a4e251428134"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.80/oversky-linux-x64"
      sha256 "96b557a3cde78a2b208524cf215dbe16a83f4215e3e118d78323d5d3a82e1548"
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
