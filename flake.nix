{
  description = "A very basic flake";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils/master";
    smunix-diagrams.url = "github:smunix/diagrams/fix.diagrams";
    smunix-diagrams-contrib.url = "github:smunix/diagrams-contrib/fix.diagrams";
    smunix-diagrams-core.url = "github:smunix/diagrams-core/fix.diagrams";
    smunix-diagrams-lib.url = "github:smunix/diagrams-lib/fix.diagrams";
    smunix-diagrams-svg.url = "github:smunix/diagrams-svg/fix.diagrams";
    smunix-monoid-extras.url = "github:smunix/monoid-extras/fix.diagrams";
  }; 
  outputs =
    { self, nixpkgs, flake-utils, smunix-diagrams, smunix-diagrams-lib,
      smunix-diagrams-contrib, smunix-diagrams-core, smunix-diagrams-svg,
      smunix-monoid-extras,
      ...
    }:
    with flake-utils.lib;
    with nixpkgs.lib;
    eachSystem [ "x86_64-linux" ] (system:
      let version = "${substring 0 8 self.lastModifiedDate}.${self.shortRev or "dirty"}";
          overlay = self: super:
            with self;
            with haskell.lib;
            with haskellPackages.extend(self: super: {
              inherit (smunix-diagrams-contrib.packages.${system}) diagrams-contrib;
              inherit (smunix-diagrams-core.packages.${system}) diagrams-core;
              inherit (smunix-monoid-extras.packages.${system}) monoid-extras;
              inherit (smunix-diagrams-lib.packages.${system}) diagrams-lib;
              inherit (smunix-diagrams-svg.packages.${system}) diagrams-svg;
              inherit (smunix-diagrams.packages.${system}) diagrams;
              colour-space = unmarkBroken super.colour-space;
              dynamic-plot = unmarkBroken super.dynamic-plot;
              trivial-constraint = unmarkBroken super.trivial-constraint;
              constrained-categories = unmarkBroken super.constrained-categories;
            });
            {
              diagrams-manual = rec {
                package = overrideCabal (callCabal2nix "diagrams-manual" ./. {}) (o: { version = "${o.version}-${version}"; });
                apps = {
                  diagrams-manual-exe = mkApp { drv = package; exePath = "/bin/diagrams-manual-exe"; };
                };
              };
            };
          overlays = [ overlay ];
      in
        with (import nixpkgs { inherit system overlays; });
        rec {
          packages = flattenTree (recurseIntoAttrs { diagrams-manual = diagrams-manual.package; });
          defaultPackage = packages.diagrams-manual;
          inherit (diagrams-manual) apps;
          defaultApp = apps.diagrams-manual-exe;
        });
}
