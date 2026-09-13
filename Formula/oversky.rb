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
#   0.8.30                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.oversky.ai/daemon/releases/0.8.30/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   61f1d363d69be160079c9690b2b2a0c862289b6a19d77b00b8129f0782f24583       — sha256 of that asset
#   https://updates.oversky.ai/daemon/releases/0.8.30/oversky-darwin-x64, 80542374371f035b099b04334820c9a66f9465f8f476063f4093b2d302a0d173
#   https://updates.oversky.ai/daemon/releases/0.8.30/oversky-linux-x64,  19245c8e323e0b5fc117775d3a165a15a7026cb6d1ac238f46998ef4fa87401f
#   https://updates.oversky.ai/daemon/releases/0.8.30/oversky-linux-arm64, a9c8805eef6a66c422375058bde8cc6e601406ab46ad2e232faaea62c2e1f65f
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
  version "0.8.30"

  on_macos do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.30/oversky-darwin-arm64"
      sha256 "61f1d363d69be160079c9690b2b2a0c862289b6a19d77b00b8129f0782f24583"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.30/oversky-darwin-x64"
      sha256 "80542374371f035b099b04334820c9a66f9465f8f476063f4093b2d302a0d173"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.oversky.ai/daemon/releases/0.8.30/oversky-linux-arm64"
      sha256 "a9c8805eef6a66c422375058bde8cc6e601406ab46ad2e232faaea62c2e1f65f"
    end
    on_intel do
      url "https://updates.oversky.ai/daemon/releases/0.8.30/oversky-linux-x64"
      sha256 "19245c8e323e0b5fc117775d3a165a15a7026cb6d1ac238f46998ef4fa87401f"
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
