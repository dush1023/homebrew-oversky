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
#   0.8.96                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.96/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   a345146d7ebb5a349e7d2e9a0eccf3aadcd0dea894fb91731c4a4773b7f42b68       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.96/oversky-darwin-x64, f024c89d6fca7b713b63a7f2aa7e1cc0b4b2e326e6a93275ac940d0bb31c01d9
#   https://updates.skrr.ai/daemon/releases/0.8.96/oversky-linux-x64,  4f35a190951cc50b427f8337daf5d5975ee9a462006effe12b8e1125e6d1bd79
#   https://updates.skrr.ai/daemon/releases/0.8.96/oversky-linux-arm64, 0d159e2cd4bc0a26e7d92ee58481d460e7e374dc29b662afe2f5fbe4c2e5d699
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
  version "0.8.96"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.96/oversky-darwin-arm64"
      sha256 "a345146d7ebb5a349e7d2e9a0eccf3aadcd0dea894fb91731c4a4773b7f42b68"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.96/oversky-darwin-x64"
      sha256 "f024c89d6fca7b713b63a7f2aa7e1cc0b4b2e326e6a93275ac940d0bb31c01d9"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.96/oversky-linux-arm64"
      sha256 "0d159e2cd4bc0a26e7d92ee58481d460e7e374dc29b662afe2f5fbe4c2e5d699"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.96/oversky-linux-x64"
      sha256 "4f35a190951cc50b427f8337daf5d5975ee9a462006effe12b8e1125e6d1bd79"
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
