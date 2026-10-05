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
#   0.8.105                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.105/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   ce8a37ed8bd48f9a18ca2b20f21250f9b04aa9d1b211a025e4040b5431247079       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.105/oversky-darwin-x64, 2dbefeaece4073499f93a059066252616015ecbb5a17ef0a94bc3f10a75639aa
#   https://updates.skrr.ai/daemon/releases/0.8.105/oversky-linux-x64,  218a62834f94940d6ecc36dd21a4bc4e618401be2eb9b7f372e74947d022535c
#   https://updates.skrr.ai/daemon/releases/0.8.105/oversky-linux-arm64, c1c5709e9d63519cc608d4bf4e9ec65ec7337658943c787e2a7a1c5c57595814
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
  version "0.8.105"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.105/oversky-darwin-arm64"
      sha256 "ce8a37ed8bd48f9a18ca2b20f21250f9b04aa9d1b211a025e4040b5431247079"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.105/oversky-darwin-x64"
      sha256 "2dbefeaece4073499f93a059066252616015ecbb5a17ef0a94bc3f10a75639aa"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.105/oversky-linux-arm64"
      sha256 "c1c5709e9d63519cc608d4bf4e9ec65ec7337658943c787e2a7a1c5c57595814"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.105/oversky-linux-x64"
      sha256 "218a62834f94940d6ecc36dd21a4bc4e618401be2eb9b7f372e74947d022535c"
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
