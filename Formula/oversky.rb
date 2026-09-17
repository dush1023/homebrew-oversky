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
#   0.8.53                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.53/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   be10df538cd44f865a71d76e6174b5dbdf4c8c2b0d250d1586747857c3c18d21       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.53/oversky-darwin-x64, f57322afce65778ad4b79240015e1a6288a59cf59c63f73d66c1633da3d75fdf
#   https://updates.oversky.ai/daemon/releases/0.8.53/oversky-linux-x64,  0612fc3cc883cfbd1e0c87b284c62713092ad655b92d42c56e2058188793e505
#   https://updates.oversky.ai/daemon/releases/0.8.53/oversky-linux-arm64, 49337208bc41eb62876295917da83d9a30e9401072919c6fdbbbc2a79d0e94f4
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
  version "0.8.53"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.53/oversky-darwin-arm64"
      sha256 "be10df538cd44f865a71d76e6174b5dbdf4c8c2b0d250d1586747857c3c18d21"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.53/oversky-darwin-x64"
      sha256 "f57322afce65778ad4b79240015e1a6288a59cf59c63f73d66c1633da3d75fdf"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.53/oversky-linux-arm64"
      sha256 "49337208bc41eb62876295917da83d9a30e9401072919c6fdbbbc2a79d0e94f4"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.53/oversky-linux-x64"
      sha256 "0612fc3cc883cfbd1e0c87b284c62713092ad655b92d42c56e2058188793e505"
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
