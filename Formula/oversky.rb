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
#   0.8.177                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.177/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   2d8415344f6293c27ab8cf9a84412af264b3d274f31ba7315abd6a412376dac9       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.177/oversky-darwin-x64, 45199e59a8903ce3b6ece569a5a0aacb8aca788aaddb97e43a518c7261243344
#   https://updates.skrr.ai/daemon/releases/0.8.177/oversky-linux-x64,  317913638d9a6c140a29104e801fd20ecdca4b4620dd87452edc0bc85a56aaf4
#   https://updates.skrr.ai/daemon/releases/0.8.177/oversky-linux-arm64, 8bbec1cc59b313c0d85ad25592db7ce3f8650c8717088d53eb997f353abc85b6
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
  version "0.8.177"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.177/oversky-darwin-arm64"
      sha256 "2d8415344f6293c27ab8cf9a84412af264b3d274f31ba7315abd6a412376dac9"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.177/oversky-darwin-x64"
      sha256 "45199e59a8903ce3b6ece569a5a0aacb8aca788aaddb97e43a518c7261243344"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.177/oversky-linux-arm64"
      sha256 "8bbec1cc59b313c0d85ad25592db7ce3f8650c8717088d53eb997f353abc85b6"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.177/oversky-linux-x64"
      sha256 "317913638d9a6c140a29104e801fd20ecdca4b4620dd87452edc0bc85a56aaf4"
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
