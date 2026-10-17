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
#   0.8.124                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.124/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   51358f4f91e4de894e1bdba0d51494ab462d913f5b31f3f494b9ae111a36bab6       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.124/oversky-darwin-x64, c182a032b3a49b204c65fa2b3b4eb5511e388723f6e0c3a47a4753166870e5c8
#   https://updates.skrr.ai/daemon/releases/0.8.124/oversky-linux-x64,  26a1cf09541f5bb48fc7b33d01ed0370bf0d81b38d7c8c579d3eddba1517dc87
#   https://updates.skrr.ai/daemon/releases/0.8.124/oversky-linux-arm64, 60a2aad75e1152694892a31d67433e91bfa09693123a2ab2d7bd1c198290a22f
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
  version "0.8.124"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.124/oversky-darwin-arm64"
      sha256 "51358f4f91e4de894e1bdba0d51494ab462d913f5b31f3f494b9ae111a36bab6"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.124/oversky-darwin-x64"
      sha256 "c182a032b3a49b204c65fa2b3b4eb5511e388723f6e0c3a47a4753166870e5c8"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.124/oversky-linux-arm64"
      sha256 "60a2aad75e1152694892a31d67433e91bfa09693123a2ab2d7bd1c198290a22f"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.124/oversky-linux-x64"
      sha256 "26a1cf09541f5bb48fc7b33d01ed0370bf0d81b38d7c8c579d3eddba1517dc87"
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
