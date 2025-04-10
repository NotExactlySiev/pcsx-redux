{
  description = "PlayStation 1 emulator and debugger";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-github-actions.url = "github:nix-community/nix-github-actions";
    nix-github-actions.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    nix-github-actions
  }:
  let
    lib = nixpkgs.lib;
    # githubSystems = builtins.attrNames nix-github-actions.lib.githubPlatforms;
    # forAllSystems = lib.genAttrs lib.systems.flakeExposed;
    # forGithubSystems = lib.genAttrs githubSystems;
    # TODO: githubSystems should be supportedSystems intersects lib.githubPlatforms
    # Some of the dependencies don't build on clang. Will fix later
    pkgsFor = forAllSystems (system: {
      native = import nixpkgs { inherit system; };
      # For building OpenBIOS (TODO: add a github test for it)
      cross = import nixpkgs {
        localSystem = { inherit system; };
        crossSystem = { system = "mipsel-none-elf"; };
      };
    });

    supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
    forAllSystems = lib.genAttrs supportedSystems;
    forGithubSystems = lib.genAttrs supportedSystems;
    
  in {
    packages = forAllSystems (system: with pkgsFor.${system}; {
      pcsx-redux = native.callPackage ./pcsx-redux.nix {
          src = self;
          platforms = lib.systems.flakeExposed;
      };
      # FIXME: default gets duplicated in githubActions
      # default = self.packages.${system}.pcsx-redux;
    });

    devShells = forAllSystems (system: with pkgsFor.${system}; {
      default = native.mkShell {
        packages = [
          cross.buildPackages.binutils-unwrapped
          cross.buildPackages.gcc-unwrapped
        ];
      };
    });

    githubActions = nix-github-actions.lib.mkGithubMatrix {
      checks = forGithubSystems (system: self.packages.${system});
    };
  };
}
