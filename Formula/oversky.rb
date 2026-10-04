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
#   0.8.101                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.101/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   bcdbbd2272f1f7499344e1ee1a1da19373dccb7728b8747973c523fb31cf59c1       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.101/oversky-darwin-x64, 1ff55c1a9fa01450767e873c34dac5529ca5fad3eaac12a90f9fb817a06fbf68
#   https://updates.skrr.ai/daemon/releases/0.8.101/oversky-linux-x64,  2ca3f0d3c3c836f9e108de446964699cb8e72c645d139e1bfc9d73383a1f6649
#   https://updates.skrr.ai/daemon/releases/0.8.101/oversky-linux-arm64, 63e7d8fef5af1fe531ec016a57dd25b6a51715fe43aebd390a205353d9445ee6
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
  version "0.8.101"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.101/oversky-darwin-arm64"
      sha256 "bcdbbd2272f1f7499344e1ee1a1da19373dccb7728b8747973c523fb31cf59c1"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.101/oversky-darwin-x64"
      sha256 "1ff55c1a9fa01450767e873c34dac5529ca5fad3eaac12a90f9fb817a06fbf68"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.101/oversky-linux-arm64"
      sha256 "63e7d8fef5af1fe531ec016a57dd25b6a51715fe43aebd390a205353d9445ee6"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.101/oversky-linux-x64"
      sha256 "2ca3f0d3c3c836f9e108de446964699cb8e72c645d139e1bfc9d73383a1f6649"
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
