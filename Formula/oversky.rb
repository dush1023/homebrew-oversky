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
#   0.8.83                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.83/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   788c84cde2bacb958db7af0030b6abb98b9aba9277b56a27968aa1d0e2734221       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.83/oversky-darwin-x64, 80b527fa2f7a7f6859f4033cffc0c3becbec13b6238af663630760b135774032
#   https://updates.skrr.ai/daemon/releases/0.8.83/oversky-linux-x64,  9340282c0c8fce5e5026a43233755e5f1245a462dcdded4b9f5366322cccc827
#   https://updates.skrr.ai/daemon/releases/0.8.83/oversky-linux-arm64, 4c068f71a71bd959872d8d8304d439dd30cdaac461b917d5597f0b288e671aed
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
  version "0.8.83"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.83/oversky-darwin-arm64"
      sha256 "788c84cde2bacb958db7af0030b6abb98b9aba9277b56a27968aa1d0e2734221"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.83/oversky-darwin-x64"
      sha256 "80b527fa2f7a7f6859f4033cffc0c3becbec13b6238af663630760b135774032"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.83/oversky-linux-arm64"
      sha256 "4c068f71a71bd959872d8d8304d439dd30cdaac461b917d5597f0b288e671aed"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.83/oversky-linux-x64"
      sha256 "9340282c0c8fce5e5026a43233755e5f1245a462dcdded4b9f5366322cccc827"
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
