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
#   0.8.47                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.47/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   4bf7f975e2dce8f0c709f7153740ee45583434d7f3a32e5519f3da41f6803e0b       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.47/oversky-darwin-x64, 0d86b0cea23cc87f2d03c490b2a130664c12cd6f33b26469564ddada7f68e785
#   https://updates.oversky.ai/daemon/releases/0.8.47/oversky-linux-x64,  f45be0c838bade937b04d6c4c56111810ce2fd87688e647d51ef4472ea1ec62c
#   https://updates.oversky.ai/daemon/releases/0.8.47/oversky-linux-arm64, 46f0934927c2bd1403f4dd9a447ef4dced9d9a99933a761276d01d9f8b3bad64
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
  version "0.8.47"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.47/oversky-darwin-arm64"
      sha256 "4bf7f975e2dce8f0c709f7153740ee45583434d7f3a32e5519f3da41f6803e0b"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.47/oversky-darwin-x64"
      sha256 "0d86b0cea23cc87f2d03c490b2a130664c12cd6f33b26469564ddada7f68e785"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.47/oversky-linux-arm64"
      sha256 "46f0934927c2bd1403f4dd9a447ef4dced9d9a99933a761276d01d9f8b3bad64"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.47/oversky-linux-x64"
      sha256 "f45be0c838bade937b04d6c4c56111810ce2fd87688e647d51ef4472ea1ec62c"
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
