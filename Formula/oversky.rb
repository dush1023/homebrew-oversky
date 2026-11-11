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
#   0.8.159                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.159/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   c27bcf04d0d7062f3afb065c0fa39a5cd4a733f8dc017c98d6142ddd971b0534       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.159/oversky-darwin-x64, ebaacecdf5a75ae7c160150ebb5cb6ccaad673236df6c98621b149fa4e4251f2
#   https://updates.skrr.ai/daemon/releases/0.8.159/oversky-linux-x64,  591b186e302b6f103851b1460dffd3958ee56f757b51be7bc1135efd423da52e
#   https://updates.skrr.ai/daemon/releases/0.8.159/oversky-linux-arm64, 140f7491b170524ff4163e73ccf603de38fe0e348f1eb9bd851d3842ae7ba36c
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
  version "0.8.159"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.159/oversky-darwin-arm64"
      sha256 "c27bcf04d0d7062f3afb065c0fa39a5cd4a733f8dc017c98d6142ddd971b0534"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.159/oversky-darwin-x64"
      sha256 "ebaacecdf5a75ae7c160150ebb5cb6ccaad673236df6c98621b149fa4e4251f2"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.159/oversky-linux-arm64"
      sha256 "140f7491b170524ff4163e73ccf603de38fe0e348f1eb9bd851d3842ae7ba36c"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.159/oversky-linux-x64"
      sha256 "591b186e302b6f103851b1460dffd3958ee56f757b51be7bc1135efd423da52e"
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
