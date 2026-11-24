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
#   0.8.193                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.193/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   30795358718c5c60c86f4c0f2b7f6cdfd6f7a4df7430c96efabd7007bcba8bce       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.193/oversky-darwin-x64, 7b8b362d96928a04aa059620b7c5411a1c80515451a18f887c53d5c493b9d7c8
#   https://updates.skrr.ai/daemon/releases/0.8.193/oversky-linux-x64,  432cac67e4b67f69da291b779505923431244fbcffab260dad2bff7a0b7343b4
#   https://updates.skrr.ai/daemon/releases/0.8.193/oversky-linux-arm64, d8b78d212d8a2eff50aff3f7f508cb93f150343ed2d2a8f5f69e4f3944af74be
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
  version "0.8.193"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.193/oversky-darwin-arm64"
      sha256 "30795358718c5c60c86f4c0f2b7f6cdfd6f7a4df7430c96efabd7007bcba8bce"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.193/oversky-darwin-x64"
      sha256 "7b8b362d96928a04aa059620b7c5411a1c80515451a18f887c53d5c493b9d7c8"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.193/oversky-linux-arm64"
      sha256 "d8b78d212d8a2eff50aff3f7f508cb93f150343ed2d2a8f5f69e4f3944af74be"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.193/oversky-linux-x64"
      sha256 "432cac67e4b67f69da291b779505923431244fbcffab260dad2bff7a0b7343b4"
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
