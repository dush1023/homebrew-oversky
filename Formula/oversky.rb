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
#   0.8.58                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.58/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   7606bbc274bab9e4d72ceceeb91b012386a263951c2b03ea9ef2f56c86318947       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.58/oversky-darwin-x64, 8699896a48f0c57fcafaef0a4ad45c6cadd060be09bd28bb3fc35c3a2975ecc6
#   https://updates.oversky.ai/daemon/releases/0.8.58/oversky-linux-x64,  316d7cc1b43bedbafe516a50334df7c928ded7777539b7e7d933a7b9e53d57c0
#   https://updates.oversky.ai/daemon/releases/0.8.58/oversky-linux-arm64, d74bec0fe86ab52c18465546ca1bfae3a44ae766cfa62a8ea0a4d38295d8eee9
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
  version "0.8.58"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.58/oversky-darwin-arm64"
      sha256 "7606bbc274bab9e4d72ceceeb91b012386a263951c2b03ea9ef2f56c86318947"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.58/oversky-darwin-x64"
      sha256 "8699896a48f0c57fcafaef0a4ad45c6cadd060be09bd28bb3fc35c3a2975ecc6"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.58/oversky-linux-arm64"
      sha256 "d74bec0fe86ab52c18465546ca1bfae3a44ae766cfa62a8ea0a4d38295d8eee9"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.58/oversky-linux-x64"
      sha256 "316d7cc1b43bedbafe516a50334df7c928ded7777539b7e7d933a7b9e53d57c0"
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
