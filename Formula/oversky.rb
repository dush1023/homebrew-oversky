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
#   0.8.203                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.203/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   12391a5ac84184a6d48db94a5c90c945653972f1edf343b7d4cc4f7e9244620f       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.203/oversky-darwin-x64, 63dd7b9384d5ce830519aa580dc7a6d40c36af9384faf91635936e06767e41a5
#   https://updates.skrr.ai/daemon/releases/0.8.203/oversky-linux-x64,  dc56e84c7b5fc51843f29783fa59dd447457d58b69f197c6ae386734efbc03fc
#   https://updates.skrr.ai/daemon/releases/0.8.203/oversky-linux-arm64, 891217bf644929bb8fc96fd2e01705f9f119dea230cfe26458e359f1f1664035
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
  homepage "https://github.com/skrr-ai/OverSky"
  license "UNLICENSED"
  version "0.8.203"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.203/oversky-darwin-arm64"
      sha256 "12391a5ac84184a6d48db94a5c90c945653972f1edf343b7d4cc4f7e9244620f"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.203/oversky-darwin-x64"
      sha256 "63dd7b9384d5ce830519aa580dc7a6d40c36af9384faf91635936e06767e41a5"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.203/oversky-linux-arm64"
      sha256 "891217bf644929bb8fc96fd2e01705f9f119dea230cfe26458e359f1f1664035"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.203/oversky-linux-x64"
      sha256 "dc56e84c7b5fc51843f29783fa59dd447457d58b69f197c6ae386734efbc03fc"
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
