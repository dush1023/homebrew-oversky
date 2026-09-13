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
#   0.8.26                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.26/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   1b0fa4263505ee48114d8ad5bee3d67b8a40fc32cf178e4a8a153e9bf95fcbde       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.26/oversky-darwin-x64, 95dee1ca7428186ab2219fc725672b8b23fca7a969276498417f279b90f32dec
#   https://updates.oversky.ai/daemon/releases/0.8.26/oversky-linux-x64,  1bd1972c0e955121bc2fe12bd8bd5f4cd8e541852131a279bf1b71baaa96f1ae
#   https://updates.oversky.ai/daemon/releases/0.8.26/oversky-linux-arm64, 8bb300b95365755bd368f037771cd5a5d3464f6d952a4bbf9fe967e9f38fdf62
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
  version "0.8.26"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.26/oversky-darwin-arm64"
      sha256 "1b0fa4263505ee48114d8ad5bee3d67b8a40fc32cf178e4a8a153e9bf95fcbde"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.26/oversky-darwin-x64"
      sha256 "95dee1ca7428186ab2219fc725672b8b23fca7a969276498417f279b90f32dec"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.26/oversky-linux-arm64"
      sha256 "8bb300b95365755bd368f037771cd5a5d3464f6d952a4bbf9fe967e9f38fdf62"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.26/oversky-linux-x64"
      sha256 "1bd1972c0e955121bc2fe12bd8bd5f4cd8e541852131a279bf1b71baaa96f1ae"
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
