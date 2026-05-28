{
  description = "Standalone build of dav1d (AV1 decoder CLI)";

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
      withTools = scope: ulib.nativeFixes.dav1d (scope // {
        dav1d = scope.dav1d.override { withTools = true; };
      });
    in
    ulib.mkStandaloneFlake {
      inherit self;
      name = "dav1d";
      build         = pkgs: withTools pkgs.pkgsStatic;
      windowsBuild  = pkgs: withTools (ulib.mingwStaticCross pkgs);
    };
}
