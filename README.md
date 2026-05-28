# dav1d

Standalone build of [dav1d](https://code.videolan.org/videolan/dav1d) — VideoLAN's AV1 decoder, reference for decode performance.

[![CI](https://github.com/unpins/dav1d/actions/workflows/dav1d.yml/badge.svg)](https://github.com/unpins/dav1d/actions)
![Linux](https://img.shields.io/badge/Linux-✓-success?logo=linux&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-✓-success?logo=apple&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-✓-success?logo=windows&logoColor=white)

Part of the [unpins](https://unpins.org) project — native single-binary builds with no third-party runtime dependencies.

Decodes AV1 bitstreams from `.ivf` containers. Also doubles as the de-facto AV1 decode benchmark.

## Installation

Install with [unpin](https://github.com/unpins/unpin):

```bash
unpin dav1d
```

Or run without installing:

```bash
unpin run dav1d
```

## Build locally

```bash
nix build github:unpins/dav1d
./result/bin/dav1d --version
```

Or run directly:

```bash
nix run github:unpins/dav1d -- -i input.ivf -o output.yuv
```

The first invocation will offer to add the [unpins.cachix.org](https://unpins.cachix.org) substituter so most pulls come pre-built.

## Manual download

The [Releases](https://github.com/unpins/dav1d/releases) page has standalone binaries for manual download.

## Build notes

- **Windows:** `mingw` cross, single `.exe`, no companion DLLs.
- **No upstream features disabled** on any platform.

Platform fixes live in [`nix-lib/native-overlay/dav1d.nix`](https://github.com/unpins/nix-lib/blob/main/native-overlay/dav1d.nix).
