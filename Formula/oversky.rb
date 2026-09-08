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
#   0.8.16                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.16/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   4ff7eb671769718480f47935cacadbbbc3501ede9ebcbb35de8ef7ef49ca9bfb       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.16/oversky-darwin-x64, 62a79d4ce66b7e97fcf1fe4e1da3c93718be2a000569c24f2c595ce4c1a71376
#   https://updates.oversky.ai/daemon/releases/0.8.16/oversky-linux-x64,  60467450165271695bcc292041d4259653289a8c7632236efed271f1053dc856
#   https://updates.oversky.ai/daemon/releases/0.8.16/oversky-linux-arm64, 7d93bb3dc91a4f2a1b51422a2d9f8a8e8e2a99a3c3ea10500383accd0445a763
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
  version "0.8.16"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.16/oversky-darwin-arm64"
      sha256 "4ff7eb671769718480f47935cacadbbbc3501ede9ebcbb35de8ef7ef49ca9bfb"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.16/oversky-darwin-x64"
      sha256 "62a79d4ce66b7e97fcf1fe4e1da3c93718be2a000569c24f2c595ce4c1a71376"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.16/oversky-linux-arm64"
      sha256 "7d93bb3dc91a4f2a1b51422a2d9f8a8e8e2a99a3c3ea10500383accd0445a763"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.16/oversky-linux-x64"
      sha256 "60467450165271695bcc292041d4259653289a8c7632236efed271f1053dc856"
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
