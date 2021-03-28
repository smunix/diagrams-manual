{
  description = "A very basic flake";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils/master";
    smunix-diagrams.url = "github:smunix/diagrams/fix.diagrams";
    smunix-diagrams-contrib.url = "github:smunix/diagrams-contrib/fix.diagrams";
    smunix-diagrams-core.url = "github:smunix/diagrams-core/fix.diagrams";
    smunix-diagrams-cairo.url = "github:smunix/diagrams-cairo/fix.diagrams";
    smunix-diagrams-gtk.url = "github:smunix/diagrams-gtk/fix.diagrams";
    smunix-diagrams-lib.url = "github:smunix/diagrams-lib/fix.diagrams";
    smunix-diagrams-svg.url = "github:smunix/diagrams-svg/fix.diagrams";
    smunix-monoid-extras.url = "github:smunix/monoid-extras/fix.diagrams";
  }; 
  outputs =
    { self, nixpkgs, flake-utils, smunix-diagrams, smunix-diagrams-lib,
      smunix-diagrams-contrib, smunix-diagrams-core, smunix-diagrams-svg,
      smunix-monoid-extras, smunix-diagrams-cairo, smunix-diagrams-gtk,
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
              inherit (smunix-diagrams-cairo.packages.${system}) diagrams-cairo;
              inherit (smunix-diagrams-gtk.packages.${system}) diagrams-gtk;
              inherit (smunix-monoid-extras.packages.${system}) monoid-extras;
              inherit (smunix-diagrams-lib.packages.${system}) diagrams-lib;
              inherit (smunix-diagrams-svg.packages.${system}) diagrams-svg;
              inherit (smunix-diagrams.packages.${system}) diagrams;
              colour-space = unmarkBroken super.colour-space;
              trivial-constraint =
                super.callCabal2nix "trivial-constraint" (fetchFromGitHub {
                  owner = "leftaroundabout";
                  repo = "trivial-constraint";
                  rev = "8ad79abb16a8f04916f7ac004a7c850d3e1c300e";
                  sha256 = "0vc9qg127929rzix0x25nm65adj1ibj0v7rwnsks3z1g10w7lz7q";
                }) {};              
              dynamic-plot =
                super.callCabal2nix "dynamic-plot" (fetchFromGitHub {
                  owner = "leftaroundabout";
                  repo = "dynamic-plot";
                  rev = "3284c7b99f8ff077f50241ef856054b075d04c85";
                  sha256 = "1bxsc2qqkglv31ijdc46lvpfivsq8nw9sqafhkr1xqbj242fl79d";
                }) {};              
              constrained-categories = unmarkBroken super.constrained-categories;
              linearmap-category = unmarkBroken super.linearmap-category;
              manifolds = unmarkBroken super.manifolds;
              manifold-random = unmarkBroken super.manifold-random;
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
