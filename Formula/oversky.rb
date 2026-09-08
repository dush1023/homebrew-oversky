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
#   https://updates.oversky.ai/daemon/releases/<version>
# and each URL resolves to <BASE>/oversky-<platform>-<arch>. Keep that BASE in
# lockstep with scripts/install-daemon.sh's download base.
#
# Placeholders (all single-quoted so shell interpolation can't clash):
#   0.8.13                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.13/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   c22af87677c91d38c0b308fb37dc98c1effe344ef5f9b4bab20e91d6747aed32       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.13/oversky-darwin-x64, 245f2e16c478ab392390f8ef758f62f5963b342a42f0829d754794de78c7354f
#   https://updates.oversky.ai/daemon/releases/0.8.13/oversky-linux-x64,  40af5a287c2fa64c5e1bd08c5c4a5c4639e9a965dd883c76ee124babf280e9b4
#   https://updates.oversky.ai/daemon/releases/0.8.13/oversky-linux-arm64, 661f1d57ea4a7e860a9c704d3337a7907d22f533eff1073b36071683e3709124
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
  version "0.8.13"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.13/oversky-darwin-arm64"
      sha256 "c22af87677c91d38c0b308fb37dc98c1effe344ef5f9b4bab20e91d6747aed32"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.13/oversky-darwin-x64"
      sha256 "245f2e16c478ab392390f8ef758f62f5963b342a42f0829d754794de78c7354f"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.13/oversky-linux-arm64"
      sha256 "661f1d57ea4a7e860a9c704d3337a7907d22f533eff1073b36071683e3709124"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.13/oversky-linux-x64"
      sha256 "40af5a287c2fa64c5e1bd08c5c4a5c4639e9a965dd883c76ee124babf280e9b4"
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
