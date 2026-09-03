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
#   0.8.10                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.10/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   642537bf3a46ceb67015b5cd65408be148e77ef166d8c6d07c6eb1cfa3e191a1       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.10/oversky-darwin-x64, 4cea4c0e622e8368268a86518eaad2445dd1d7a0d9b9980d24a28b4b50367fcf
#   https://updates.oversky.ai/daemon/releases/0.8.10/oversky-linux-x64,  aab4794994054c4a01bb0b8a026cff1dc93a22a79b2074ef4adee750cb6ce824
#   https://updates.oversky.ai/daemon/releases/0.8.10/oversky-linux-arm64, 13eeaacb21ad962383df41ff693be5aa3a8f8649bcf0a0418d337a9ecd95a314
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
  version "0.8.10"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.10/oversky-darwin-arm64"
      sha256 "642537bf3a46ceb67015b5cd65408be148e77ef166d8c6d07c6eb1cfa3e191a1"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.10/oversky-darwin-x64"
      sha256 "4cea4c0e622e8368268a86518eaad2445dd1d7a0d9b9980d24a28b4b50367fcf"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.10/oversky-linux-arm64"
      sha256 "13eeaacb21ad962383df41ff693be5aa3a8f8649bcf0a0418d337a9ecd95a314"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.10/oversky-linux-x64"
      sha256 "aab4794994054c4a01bb0b8a026cff1dc93a22a79b2074ef4adee750cb6ce824"
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
