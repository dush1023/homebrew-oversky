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
#   0.8.17                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.17/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   23cff2d999b5d63989e1d987465673de4f236d78f4f89d5e23d137a2242a9ded       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.17/oversky-darwin-x64, 57dc2f1d66fce4ce116aa7b7495399e34044b2fb16f9604b0b009f88e0a7ca9e
#   https://updates.oversky.ai/daemon/releases/0.8.17/oversky-linux-x64,  d00bc72c3e352eade467a1cf7951fb55270480a9eec4f2095f083b1dd62733b0
#   https://updates.oversky.ai/daemon/releases/0.8.17/oversky-linux-arm64, 19077aedea7b5e368dd1d0da58d40d15f6a826fe3273614d1e5fda797f5d8d46
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
  version "0.8.17"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.17/oversky-darwin-arm64"
      sha256 "23cff2d999b5d63989e1d987465673de4f236d78f4f89d5e23d137a2242a9ded"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.17/oversky-darwin-x64"
      sha256 "57dc2f1d66fce4ce116aa7b7495399e34044b2fb16f9604b0b009f88e0a7ca9e"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.17/oversky-linux-arm64"
      sha256 "19077aedea7b5e368dd1d0da58d40d15f6a826fe3273614d1e5fda797f5d8d46"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.17/oversky-linux-x64"
      sha256 "d00bc72c3e352eade467a1cf7951fb55270480a9eec4f2095f083b1dd62733b0"
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
