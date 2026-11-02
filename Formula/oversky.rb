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
#   0.8.145                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.145/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   6e769ae2189d4653607d2e0304efd2fb325d0dc59b712e1a2fb3bc316db214e7       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.145/oversky-darwin-x64, 10a5b9ddf2e0792ab2ce29b070457630031852bebf60f45be276cc7f99be0886
#   https://updates.skrr.ai/daemon/releases/0.8.145/oversky-linux-x64,  9dbdc7e46d6eef1052efa3b79c31e3a5ba8c9674c9b4e17bd2289b709c2ba022
#   https://updates.skrr.ai/daemon/releases/0.8.145/oversky-linux-arm64, 5db330cf80c35be1a97ffd84630daea545e6a6b80a23657bd6461be5cb2aacaf
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
  version "0.8.145"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.145/oversky-darwin-arm64"
      sha256 "6e769ae2189d4653607d2e0304efd2fb325d0dc59b712e1a2fb3bc316db214e7"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.145/oversky-darwin-x64"
      sha256 "10a5b9ddf2e0792ab2ce29b070457630031852bebf60f45be276cc7f99be0886"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.145/oversky-linux-arm64"
      sha256 "5db330cf80c35be1a97ffd84630daea545e6a6b80a23657bd6461be5cb2aacaf"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.145/oversky-linux-x64"
      sha256 "9dbdc7e46d6eef1052efa3b79c31e3a5ba8c9674c9b4e17bd2289b709c2ba022"
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
