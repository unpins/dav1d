# dav1d

[dav1d](https://code.videolan.org/videolan/dav1d) — VideoLAN's AV1 decoder, reference for decode performance. A single self-contained binary, built natively for Linux, macOS, and Windows.

[![CI](https://github.com/unpins/dav1d/actions/workflows/dav1d.yml/badge.svg)](https://github.com/unpins/dav1d/actions)
![Linux](https://img.shields.io/badge/Linux-✓-success?logo=linux&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-✓-success?logo=apple&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-✓-success?logo=windows&logoColor=white)

Part of the [unpins](https://unpins.org) catalog; install it with [`unpin`](https://github.com/unpins/unpin): `unpin install dav1d`.

Decodes AV1 bitstreams from `.ivf` containers. Also doubles as the de-facto AV1 decode benchmark.

## Usage

Run the `dav1d` program with [unpin](https://github.com/unpins/unpin):

```bash
unpin dav1d -i input.ivf -o output.yuv    # decode an AV1 bitstream to YUV
```

To install it onto your PATH:

```bash
unpin install dav1d
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
- **Tests:** upstream's `checkasm` suite (every optimized SIMD kernel verified against its C reference) plus the header tests run as part of the build on every native target — x86_64 / aarch64 / i686, Linux and macOS — and must pass 0-fail (7/7 OK). Foreign cross targets (mingw, ppc64le, riscv64) build without checks, since the host binary can't execute on the builder.

Platform fixes live in [`nix-lib/native-overlay/dav1d.nix`](https://github.com/unpins/nix-lib/blob/main/native-overlay/dav1d.nix).
