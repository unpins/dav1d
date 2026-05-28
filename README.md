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

- **Windows variant:** `mingw` (cross from Linux). No POSIX gaps — dav1d is plain C / asm with its own thread abstraction.
- **`meson.build` `arm64` substitution**: nixpkgs writes `cpu_family='arm64'` rather than `'aarch64'` into the meson cross-file on Apple Silicon. dav1d's existing `arm64` fallback in `src/meson.build` checks `cpu()` not `cpu_family()`, so it doesn't fire for nixpkgs' value layout. The shared `nativeFixes.dav1d` runs a recursive `find -name meson.build` to: (a) accept `arm64` alongside `aarch64`, (b) exclude `arm64` from `.startswith('arm')` 32-bit dispatch. Without it, aarch64-darwin tries to assemble `src/arm/32/*.S` (ARM-32 mnemonics) with the arm64 toolchain and fails. The override lives in [`nix-lib/native-overlay/dav1d.nix`](https://github.com/unpins/nix-lib/blob/main/native-overlay/dav1d.nix).
- **No embedded resources.** Decoder is fully self-contained.
- **No upstream features disabled.** Same decode capabilities on every platform.
