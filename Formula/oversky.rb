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
#   0.8.51                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.51/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   18aeb0d9bfc6b60f6c9f28ae7133e55cf07a2a402acf742027088f9d26c9f4a9       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.51/oversky-darwin-x64, e1fa96a8ef16a04221fd8cdd87e142abe5dc395bc5b6b304f395a4651f03265b
#   https://updates.oversky.ai/daemon/releases/0.8.51/oversky-linux-x64,  a14c1895d7602d180a884df7dc2739ef2d7931a7023fe12ce17e1a89a009fc7f
#   https://updates.oversky.ai/daemon/releases/0.8.51/oversky-linux-arm64, 8a27455510f06100fbffa0b728cdb5f99ecd7e5a1a6c0dddb0819ac5d241abd6
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
  version "0.8.51"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.51/oversky-darwin-arm64"
      sha256 "18aeb0d9bfc6b60f6c9f28ae7133e55cf07a2a402acf742027088f9d26c9f4a9"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.51/oversky-darwin-x64"
      sha256 "e1fa96a8ef16a04221fd8cdd87e142abe5dc395bc5b6b304f395a4651f03265b"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.51/oversky-linux-arm64"
      sha256 "8a27455510f06100fbffa0b728cdb5f99ecd7e5a1a6c0dddb0819ac5d241abd6"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.51/oversky-linux-x64"
      sha256 "a14c1895d7602d180a884df7dc2739ef2d7931a7023fe12ce17e1a89a009fc7f"
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
