{
  description = "Standalone build of dav1d (AV1 decoder CLI)";

  nixConfig = {
    extra-substituters = [ "https://unpins.cachix.org" ];
    extra-trusted-public-keys = [ "unpins.cachix.org-1:DDaShjbZ8VvcqxeTcAU3kV9vxZQBlyb7V/uLBHfTynI=" ];
  };

  inputs.unpins-lib.url = "github:unpins/nix-lib";

  # Single CLI upstream (`dav1d`). `pkgsStatic.dav1d` cross-builds cleanly on
  # linux / darwin (incl. aarch64) / mingw with the shared
  # `nativeFixes.dav1d` applied: a `find -name meson.build` substitution that
  # routes meson's `cpu_family='arm64'` on Apple Silicon to the AArch64 asm
  # dispatch (nixpkgs writes 'arm64' rather than 'aarch64' into the cross-
  # file, so dav1d's existing arm64 fallback in src/meson.build doesn't
  # fire). See nix-lib/native-overlay/dav1d.nix.
  outputs = { self, unpins-lib }:
    let ulib = unpins-lib.lib; in
    ulib.mkStandaloneFlake {
      inherit self;
      name = "dav1d";
      build         = pkgs: ulib.nativeFixes.dav1d pkgs.pkgsStatic;
      windowsBuild  = pkgs: ulib.nativeFixes.dav1d (ulib.mingwStaticCross pkgs);
    };
}
