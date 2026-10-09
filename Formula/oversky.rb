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
#   0.8.115                — numeric version, no leading "v" (e.g. 0.2.3)
#   https://updates.skrr.ai/daemon/releases/0.8.115/oversky-darwin-arm64       — CloudFront feed URL for oversky-darwin-arm64
#   2acff3c954f82fb1fdd4c259e9ca3882c7242d3cc4ca0c95ddf8a87527a09879       — sha256 of that asset
#   https://updates.skrr.ai/daemon/releases/0.8.115/oversky-darwin-x64, 82fe37b6c90c3dc6f7a6c8d9b0a4bf6eef625a96703cb1eada5e045c2fa4a9ca
#   https://updates.skrr.ai/daemon/releases/0.8.115/oversky-linux-x64,  b1c20a7118b89170282c2ff1a9290d5169379c6896b8835cb138dd81e4e092cb
#   https://updates.skrr.ai/daemon/releases/0.8.115/oversky-linux-arm64, adec7dcdee11d13a110afa090d4f7489f529c927fda114007c6d7e909016821b
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
  version "0.8.115"

  on_macos do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.115/oversky-darwin-arm64"
      sha256 "2acff3c954f82fb1fdd4c259e9ca3882c7242d3cc4ca0c95ddf8a87527a09879"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.115/oversky-darwin-x64"
      sha256 "82fe37b6c90c3dc6f7a6c8d9b0a4bf6eef625a96703cb1eada5e045c2fa4a9ca"
    end
  end

  on_linux do
    on_arm do
      url "https://updates.skrr.ai/daemon/releases/0.8.115/oversky-linux-arm64"
      sha256 "adec7dcdee11d13a110afa090d4f7489f529c927fda114007c6d7e909016821b"
    end
    on_intel do
      url "https://updates.skrr.ai/daemon/releases/0.8.115/oversky-linux-x64"
      sha256 "b1c20a7118b89170282c2ff1a9290d5169379c6896b8835cb138dd81e4e092cb"
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
