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
#   0.8.27                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.27/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   07e5dd08760404d6e4327cd7745629f38fba4e70aaa6c9dc7b60521a5e5efe53       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.27/oversky-darwin-x64, 095fba42aed840ee20c77dbe00b82e273664543a8ed66fdc6b18afac533a1fe9
#   https://updates.oversky.ai/daemon/releases/0.8.27/oversky-linux-x64,  41fde71da47eaa494a4ce62f70571a5da9726ed76d6a0c172d581ab09810985c
#   https://updates.oversky.ai/daemon/releases/0.8.27/oversky-linux-arm64, 5f53392040d9fbf4103a89d90fd1f707f1fb259d2cc5a8dc11d0901d13fb8312
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
  version "0.8.27"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.27/oversky-darwin-arm64"
      sha256 "07e5dd08760404d6e4327cd7745629f38fba4e70aaa6c9dc7b60521a5e5efe53"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.27/oversky-darwin-x64"
      sha256 "095fba42aed840ee20c77dbe00b82e273664543a8ed66fdc6b18afac533a1fe9"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.27/oversky-linux-arm64"
      sha256 "5f53392040d9fbf4103a89d90fd1f707f1fb259d2cc5a8dc11d0901d13fb8312"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.27/oversky-linux-x64"
      sha256 "41fde71da47eaa494a4ce62f70571a5da9726ed76d6a0c172d581ab09810985c"
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
