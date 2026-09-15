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
#   0.8.43                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.43/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   f6f9649806f8f60b2e43eda4be3e3af42f20a065f72c5a4a8f4905073f8d158a       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.43/oversky-darwin-x64, 0c0d7455269fa61ad852991ca2eb16f64a6bfa43a41ce26e188b8017d49ef4f3
#   https://updates.oversky.ai/daemon/releases/0.8.43/oversky-linux-x64,  f5146e5c69b37e8d26da383cc73e9a654adaff4ecfec6c7bca35a5262f2b7a08
#   https://updates.oversky.ai/daemon/releases/0.8.43/oversky-linux-arm64, 65ff2fd76053d83850dc980d959a7ce42e87d828c24893b7f7cd51c77308cc3f
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
  version "0.8.43"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.43/oversky-darwin-arm64"
      sha256 "f6f9649806f8f60b2e43eda4be3e3af42f20a065f72c5a4a8f4905073f8d158a"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.43/oversky-darwin-x64"
      sha256 "0c0d7455269fa61ad852991ca2eb16f64a6bfa43a41ce26e188b8017d49ef4f3"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.43/oversky-linux-arm64"
      sha256 "65ff2fd76053d83850dc980d959a7ce42e87d828c24893b7f7cd51c77308cc3f"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.43/oversky-linux-x64"
      sha256 "f5146e5c69b37e8d26da383cc73e9a654adaff4ecfec6c7bca35a5262f2b7a08"
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
