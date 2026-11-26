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
#   0.8.198                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.198/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   46d07132b0ff78d275974920469cd2d0d68061017e5b2c9aa83aa716003e38c7       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.198/oversky-darwin-x64, 7a2c45cc3c35ba7c329a896abd1aab26e31dbb46ce4650420666b100772c5c97
#   https://updates.skrr.ai/daemon/releases/0.8.198/oversky-linux-x64,  c9c988f995160e59cd86c87b8f7fda6201ba6ef139d3e76caa05cb08e924ba47
#   https://updates.skrr.ai/daemon/releases/0.8.198/oversky-linux-arm64, 79bb5a23d8a7fc6add6c666592f1698dd7b710fed97cb4e4770e5f3b1f28630c
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
  version "0.8.198"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.198/oversky-darwin-arm64"
      sha256 "46d07132b0ff78d275974920469cd2d0d68061017e5b2c9aa83aa716003e38c7"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.198/oversky-darwin-x64"
      sha256 "7a2c45cc3c35ba7c329a896abd1aab26e31dbb46ce4650420666b100772c5c97"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.198/oversky-linux-arm64"
      sha256 "79bb5a23d8a7fc6add6c666592f1698dd7b710fed97cb4e4770e5f3b1f28630c"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.198/oversky-linux-x64"
      sha256 "c9c988f995160e59cd86c87b8f7fda6201ba6ef139d3e76caa05cb08e924ba47"
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
