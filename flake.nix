{
  inputs =
    {
      nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
      utils.url = "github:numtide/flake-utils";
    };

  outputs = { nixpkgs, utils, ... }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (final: prev: {
              # https://github.com/NixOS/nixpkgs/blob/a5dc7b5d3fc4176c274666ac6baaa74f1a49eafc/pkgs/development/r-modules/default.nix
              # rPackages is a function that takes an `overrides` argument
              # if it were a plain attribute set, we'd use `prev.rPackages // {...}`
              # if it were a package scope, we'd use `prev.rPackages.overrideScope {...}`
              rPackages = prev.rPackages.override {
                overrides = {
                  curl = prev.rPackages.curl.overrideDerivation (attrs: {
                    patches = [ ./configure.patch ];
                  });
                };
              };
              zig = prev.callPackage ./zig.nix { };
            })

          ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ R rPackages.readr rPackages.knitr rPackages.rmarkdown rPackages.stringr rPackages.gt rPackages.tibble quarto zig ];
        };
      }
    );
}
