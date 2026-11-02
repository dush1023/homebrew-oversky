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
#   0.8.141                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.141/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   8f573d5f2955482a98a1434d7d253473d2a496fb604650171606f21153f30cb0       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.141/oversky-darwin-x64, 4e2141c7177b9d06e6f9cab2df97618a93b55fbc6b18b34ee35db120b7a68862
#   https://updates.skrr.ai/daemon/releases/0.8.141/oversky-linux-x64,  7cf719f45516e58a3d24dc40576605e4eb2ce39b715cfe9efa004efbefb4cb89
#   https://updates.skrr.ai/daemon/releases/0.8.141/oversky-linux-arm64, 3965673f458ff3c45afc2cd91f7ba69eace56d1b7c6a9a8c7591190c57d8f05d
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
  version "0.8.141"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.141/oversky-darwin-arm64"
      sha256 "8f573d5f2955482a98a1434d7d253473d2a496fb604650171606f21153f30cb0"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.141/oversky-darwin-x64"
      sha256 "4e2141c7177b9d06e6f9cab2df97618a93b55fbc6b18b34ee35db120b7a68862"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.141/oversky-linux-arm64"
      sha256 "3965673f458ff3c45afc2cd91f7ba69eace56d1b7c6a9a8c7591190c57d8f05d"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.141/oversky-linux-x64"
      sha256 "7cf719f45516e58a3d24dc40576605e4eb2ce39b715cfe9efa004efbefb4cb89"
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
