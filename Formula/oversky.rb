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
#   0.8.23                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.23/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   baba6c18deae858b7b9d514042432ce51b33dca5e7d3ee3e01de8bcdf41f7e7a       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.23/oversky-darwin-x64, 8fdf9fad0c4d7bae709503400a19a59fb2845ec63c846c2fa3e91160ad430c02
#   https://updates.oversky.ai/daemon/releases/0.8.23/oversky-linux-x64,  dd0b9e6cae6e7235ca9292424d052378d9f0a0c6fef88b8c5dae3a51d849174d
#   https://updates.oversky.ai/daemon/releases/0.8.23/oversky-linux-arm64, 42460952d7db8abe28cee53c29528208e41c73a03a60a4ae6bc75ac074179458
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
  version "0.8.23"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.23/oversky-darwin-arm64"
      sha256 "baba6c18deae858b7b9d514042432ce51b33dca5e7d3ee3e01de8bcdf41f7e7a"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.23/oversky-darwin-x64"
      sha256 "8fdf9fad0c4d7bae709503400a19a59fb2845ec63c846c2fa3e91160ad430c02"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.23/oversky-linux-arm64"
      sha256 "42460952d7db8abe28cee53c29528208e41c73a03a60a4ae6bc75ac074179458"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.23/oversky-linux-x64"
      sha256 "dd0b9e6cae6e7235ca9292424d052378d9f0a0c6fef88b8c5dae3a51d849174d"
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
