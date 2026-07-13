# homebrew-oversky

Homebrew tap for the **OverSky daemon** — run AI agents directly on your machine.

## Install

```bash
brew tap dush1023/oversky
brew install oversky
oversky setup
```

`oversky setup` handles browser login, OS service install (launchd on macOS,
systemd on Linux), and auto-start on login.

## Upgrade

```bash
brew upgrade oversky
```

## How this tap is maintained

`Formula/oversky.rb` is **auto-generated** — never hand-edit it. On every
`daemon-v*` tag in [`dush1023/OverSky`](https://github.com/dush1023/OverSky),
the `Daemon Release` workflow compiles the signed binaries, publishes them as
GitHub Release assets, renders the formula from
`.github/brew/oversky.rb.tmpl` with the exact per-asset sha256, and commits it
here. This keeps the formula byte-for-byte in sync with the published
artifacts.
