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
  # Order matters: `.override` re-invokes the package function and would
  # discard an `overrideAttrs` applied before it, so it goes first and the
  # fix's `overrideAttrs` runs on its result (the scope passed to the fix).
  outputs = { self, unpins-lib }:
    let
      ulib = unpins-lib.lib;
      withTools = scope: (ulib.nativeFixes.dav1d (scope // {
        dav1d = scope.dav1d.override { withTools = true; };
      })).overrideAttrs (oa: {
        # Raw YUV/Y4M to stdout in binary mode on Windows; the measured
        # why is in the patch header. Shared by linux, darwin and windows
        # (inert outside _WIN32).
        patches = (oa.patches or [ ]) ++ [ ./patches/windows-binary-stdout.patch ];
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

      # Smoke floor: `dav1d --version` prints the bare version (X.Y.Z)
      # on every native ABI + the Windows runner. Pattern is a
      # version-shaped string so it can't pass on an "unknown option"
      # banner.
      smoke = [ "--version" ];
      smokePattern = "[0-9]+[.][0-9]+[.][0-9]+";

      # checkasm (every SIMD kernel against its C reference) runs because
      # nixpkgs sets `doCheck = true`; the stdenv drops it where the build
      # machine cannot run the host (windows, ppc64le, riscv64, armv7l,
      # darwin-x86_64).
      build = pkgs: withTools pkgs.pkgsStatic;
      windowsBuild = pkgs: withTools (ulib.mingwStaticCross pkgs);
    };
}
