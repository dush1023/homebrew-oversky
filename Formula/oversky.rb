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
#   0.8.12                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.12/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   677ae0253f9d724721bcbea5193f07c637ef2bb04f7a8f18464f0fa72e4cf6f2       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.12/oversky-darwin-x64, 9ea956d269c2737ace3013d226ccfb78101b22bd92bf7635a117d710cd719da2
#   https://updates.oversky.ai/daemon/releases/0.8.12/oversky-linux-x64,  83faeeecd288091de810525f74f4b55736db931b58cb0e19c01b250bc99935b8
#   https://updates.oversky.ai/daemon/releases/0.8.12/oversky-linux-arm64, 1c12b1d51c41bdd77c699bd7c4cea572086cd19bdd8abe7c74fd7cf91b6cc8f8
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
  version "0.8.12"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.12/oversky-darwin-arm64"
      sha256 "677ae0253f9d724721bcbea5193f07c637ef2bb04f7a8f18464f0fa72e4cf6f2"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.12/oversky-darwin-x64"
      sha256 "9ea956d269c2737ace3013d226ccfb78101b22bd92bf7635a117d710cd719da2"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.12/oversky-linux-arm64"
      sha256 "1c12b1d51c41bdd77c699bd7c4cea572086cd19bdd8abe7c74fd7cf91b6cc8f8"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.12/oversky-linux-x64"
      sha256 "83faeeecd288091de810525f74f4b55736db931b58cb0e19c01b250bc99935b8"
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
