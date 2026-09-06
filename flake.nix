{
  description = "dav1d (AV1 decoder CLI) as a single self-contained binary";

  nixConfig = {
    extra-substituters = [ "https://unpins.cachix.org" ];
    extra-trusted-public-keys = [ "unpins.cachix.org-1:DDaShjbZ8VvcqxeTcAU3kV9vxZQBlyb7V/uLBHfTynI=" ];
  };

  inputs.unpins-lib.url = "github:unpins/nix-lib";

  # Single CLI upstream (`dav1d`). Two layers:
  #
  # 1. `pkgs.dav1d.override { withTools = true; }` — nixpkgs' dav1d
  #    defaults to `withTools = false` (lib only, suits ffmpeg consumer
  #    via pkg-config). For the standalone CLI flake we need
  #    `-Denable_tools=true`.
  #
  # 2. `nativeFixes.dav1d` for the shared meson.build `cpu_family`
  #    substitution (nixpkgs writes `'arm64'` rather than `'aarch64'`
  #    into the Apple Silicon meson cross-file; dav1d's existing
  #    `arm64` fallback checks `cpu()` not `cpu_family()` so it never
  #    fires). See nix-lib/native-overlay/dav1d.nix.
  #
  # Order matters: `.override` re-invokes the function, so we apply
  # it first and feed the result into `overrideAttrs` via the scope
  # extend pattern (see [[override-arg-kills-overlay-overrideattrs]]).
  outputs = { self, unpins-lib }:
    let
      ulib = unpins-lib.lib;
      withTools = scope: (ulib.nativeFixes.dav1d (scope // {
        dav1d = scope.dav1d.override { withTools = true; };
      })).overrideAttrs (oa: {
        # `-o -` sends the decoded frames to stdout, and Windows opens
        # stdout in text mode: every 0x0A byte in the raw YUV or Y4M
        # stream becomes 0x0D 0x0A and the output is corrupt. Measured on
        # Windows 10 with a five-frame clip — `--muxer yuv` wrote 30728
        # bytes where every other platform writes 30720, `--muxer
        # yuv4mpeg2` 30804 against 30790: exactly one extra byte per line
        # feed. Writing to a named file was always fine, it opens with
        # "wb"; only the `-` branch inherits the CRT default. Upstream has
        # no `_setmode` anywhere in 1.5.3.
        #
        # The checksum muxers (md5, xxh3) keep text mode on purpose. Their
        # output is a digest line, and CRLF is what a Windows text file
        # should have.
        postPatch = (oa.postPatch or "") + ''
          for f in tools/output/yuv.c tools/output/y4m2.c; do
            substituteInPlace "$f" \
              --replace-fail '#include "output/muxer.h"' '#ifdef _WIN32
          #include <fcntl.h>
          #include <io.h>
          #endif

          #include "output/muxer.h"' \
              --replace-fail 'c->f = stdout;' 'c->f = stdout;
          #ifdef _WIN32
                  _setmode(_fileno(stdout), _O_BINARY);
          #endif'
          done
        '';
      });
    in
    ulib.mkStandaloneFlake {
      inherit self;
      name = "dav1d";

      # Build via the unpin-llvm engine + emit a bitcode multicall module.
      engine = "unpin-llvm";
      multicall = {
        # The `.exe` on the engine too, not the nixpkgs mingw-gcc cross.
        windows = true;
        # dav1d ships no man page upstream, so `unpin man dav1d` has
        # nothing to show. Declared rather than left blank, but be clear
        # about what it buys today: the CI sweep walks the announced
        # ALIAS list, which is empty for a single-program package, so it
        # checks neither this waiver nor the primary name. The gap is the
        # catalog's, not this package's; the line is here so the waiver
        # is already true when the sweep learns to read the primary name.
        programs = [{ name = "dav1d"; noMan = true; }];
      };

      # Smoke floor: `dav1d --version` prints the bare version (e.g.
      # `1.5.2`) on every native ABI + the Windows runner. Pattern is a
      # version-shaped string so it can't pass on an "unknown option"
      # banner.
      smoke = [ "--version" ];
      smokePattern = "[0-9]+[.][0-9]+[.][0-9]+";

      build = pkgs:
        # nixpkgs ships dav1d with `doCheck = true` — the meson suite runs
        # `checkasm` (every optimized SIMD kernel verified against its C
        # reference) plus the header-compile tests. pkgsStatic forces
        # doCheck off on the cross-ish musl build, so re-enable it wherever
        # the build platform can run the host binary: native x86_64/aarch64
        # plus 32-bit-on-64 (i686). checkasm is precisely the test that
        # matters for a decoder, and it passed on musl-static here. Foreign
        # cross targets (mingw, ppc64le, riscv64, darwin-from-linux) keep it
        # off — `canExecute` is false there.
        (withTools pkgs.pkgsStatic).overrideAttrs (_: {
          doCheck = pkgs.pkgsStatic.stdenv.buildPlatform.canExecute
            pkgs.pkgsStatic.stdenv.hostPlatform;
        });
      windowsBuild = pkgs: withTools (ulib.mingwStaticCross pkgs);
    };
}
