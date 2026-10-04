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
#   0.8.99                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.99/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   a55a5b8a4875cc8514efdf2cd695f6eb9c143215c2d64fe16f6c04e87641d1f2       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.99/oversky-darwin-x64, 8d3ccf4a8d76f2efa9bc84d0ca044b4cb7ed893a7fd1ac72cf1321e132d924bb
#   https://updates.skrr.ai/daemon/releases/0.8.99/oversky-linux-x64,  d3f597ac902bf2b5c7b55c27996e7f28b96ddbdfaaa4f0d0a57c651ac224c7f8
#   https://updates.skrr.ai/daemon/releases/0.8.99/oversky-linux-arm64, 974ddd2fcdeb6cc89c27ce930ee869a182296249c11d11176874ff6b502bb118
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
  version "0.8.99"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.99/oversky-darwin-arm64"
      sha256 "a55a5b8a4875cc8514efdf2cd695f6eb9c143215c2d64fe16f6c04e87641d1f2"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.99/oversky-darwin-x64"
      sha256 "8d3ccf4a8d76f2efa9bc84d0ca044b4cb7ed893a7fd1ac72cf1321e132d924bb"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.99/oversky-linux-arm64"
      sha256 "974ddd2fcdeb6cc89c27ce930ee869a182296249c11d11176874ff6b502bb118"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.99/oversky-linux-x64"
      sha256 "d3f597ac902bf2b5c7b55c27996e7f28b96ddbdfaaa4f0d0a57c651ac224c7f8"
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
