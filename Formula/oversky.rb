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
#   0.8.79                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.79/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   d2536932f5438787bf2b8579e661bc735c6ae954c6b107c9fa28b54972dd1057       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.79/oversky-darwin-x64, 2bb26549d8d535ce2dfd5c51ac9d5cef21c40c3a46c4584ff8e88f63baaf2cad
#   https://updates.skrr.ai/daemon/releases/0.8.79/oversky-linux-x64,  eca39e51813cf070881b9169a9672186730f0dbf8771dc78d56f91dbdf729f65
#   https://updates.skrr.ai/daemon/releases/0.8.79/oversky-linux-arm64, 64e0b377087e8e9a2dedf6422ac0f43f1237cfec2b0641a5fc4acbed8c0cb7a0
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
  version "0.8.79"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.79/oversky-darwin-arm64"
      sha256 "d2536932f5438787bf2b8579e661bc735c6ae954c6b107c9fa28b54972dd1057"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.79/oversky-darwin-x64"
      sha256 "2bb26549d8d535ce2dfd5c51ac9d5cef21c40c3a46c4584ff8e88f63baaf2cad"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.79/oversky-linux-arm64"
      sha256 "64e0b377087e8e9a2dedf6422ac0f43f1237cfec2b0641a5fc4acbed8c0cb7a0"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.79/oversky-linux-x64"
      sha256 "eca39e51813cf070881b9169a9672186730f0dbf8771dc78d56f91dbdf729f65"
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
