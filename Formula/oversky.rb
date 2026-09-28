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
#   0.8.73                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.73/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   2be6758387fa8f14c38896438222cb40e7e501ca9c4d4fe9a79ab2cb2c425d86       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.73/oversky-darwin-x64, e75140967e872bbe63e15d2b444462aa4db366151944253fe2c0d1aa74235afb
#   https://updates.skrr.ai/daemon/releases/0.8.73/oversky-linux-x64,  bdbd72a72e640d9d0924f01d5a8f1d3d727b4910a7122d310288b0228ae9fe18
#   https://updates.skrr.ai/daemon/releases/0.8.73/oversky-linux-arm64, 84772ab87e95e5e7a2f5763ad396c4578c51ea1b69f3b7125f416146d67e366b
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
  version "0.8.73"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.73/oversky-darwin-arm64"
      sha256 "2be6758387fa8f14c38896438222cb40e7e501ca9c4d4fe9a79ab2cb2c425d86"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.73/oversky-darwin-x64"
      sha256 "e75140967e872bbe63e15d2b444462aa4db366151944253fe2c0d1aa74235afb"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.73/oversky-linux-arm64"
      sha256 "84772ab87e95e5e7a2f5763ad396c4578c51ea1b69f3b7125f416146d67e366b"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.73/oversky-linux-x64"
      sha256 "bdbd72a72e640d9d0924f01d5a8f1d3d727b4910a7122d310288b0228ae9fe18"
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
