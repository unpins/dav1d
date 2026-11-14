# dav1d

[dav1d](https://code.videolan.org/videolan/dav1d) — VideoLAN's AV1 decoder, reference for decode performance. A single self-contained binary, built natively for Linux, macOS, and Windows.

[![CI](https://github.com/unpins/dav1d/actions/workflows/dav1d.yml/badge.svg)](https://github.com/unpins/dav1d/actions)
![Linux](https://img.shields.io/badge/Linux-✓-success?logo=linux&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-✓-success?logo=apple&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-✓-success?logo=windows&logoColor=white)

Part of the [unpins](https://unpins.org) catalog; install it with [`unpin`](https://github.com/unpins/unpin): `unpin install dav1d`.

Decodes AV1 from IVF files and raw OBU streams (Annex B, Section 5). Also doubles as the de-facto AV1 decode benchmark.

## Usage

Run the `dav1d` program with [unpin](https://github.com/unpins/unpin):

```bash
unpin dav1d -i input.ivf -o output.yuv          # decode an AV1 bitstream to YUV
unpin dav1d -i input.ivf -o - --muxer yuv4mpeg2 # or write Y4M to standard output
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

- **Windows:** built with mingw-w64.
- **Not included:** `dav1dplay`, the SDL example player (upstream builds it only on request, and nixpkgs does not).
- **No man page.** dav1d ships none upstream, so there is nothing to embed — `unpin man dav1d` has no page to show. `dav1d --help` documents the options.
- **Tests:** `checkasm` (every SIMD kernel against its C reference) and the header tests run on Linux x86_64, aarch64 and i686 and on macOS Apple Silicon (0 failures under static-musl); Windows, ppc64le, riscv64, armv7l and macOS Intel are built without them, because the build machine can't execute those targets.
