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
#   0.8.106                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.106/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   dc0f230a33db9313d3c63a2aba9e35d6cd2392441b9e0b284fd09ce5d4ad06a8       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.106/oversky-darwin-x64, de0d027a4c37a56e65b902e7f25216ffecfb4b96afd05b6a6bb7d2443d953f32
#   https://updates.skrr.ai/daemon/releases/0.8.106/oversky-linux-x64,  ee589b204a2eefe7a3d900898311dcdd4d5fdf9c5020c11ce963708669ab1ccb
#   https://updates.skrr.ai/daemon/releases/0.8.106/oversky-linux-arm64, d4c9d2c0869d2b409475b5c9fff8bbfa668f55027c92db5119668efc8bf442c6
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
  version "0.8.106"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.106/oversky-darwin-arm64"
      sha256 "dc0f230a33db9313d3c63a2aba9e35d6cd2392441b9e0b284fd09ce5d4ad06a8"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.106/oversky-darwin-x64"
      sha256 "de0d027a4c37a56e65b902e7f25216ffecfb4b96afd05b6a6bb7d2443d953f32"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.106/oversky-linux-arm64"
      sha256 "d4c9d2c0869d2b409475b5c9fff8bbfa668f55027c92db5119668efc8bf442c6"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.106/oversky-linux-x64"
      sha256 "ee589b204a2eefe7a3d900898311dcdd4d5fdf9c5020c11ce963708669ab1ccb"
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
