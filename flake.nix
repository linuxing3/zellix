{
  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.default = pkgs.writeTextFile {
          name = "zl";
          executable = true;
          destination = "/bin/zl";
          text =
            builtins.readFile ./run.nu;
        };
        app.default = {
          type = "app";
          program = "${self.packages.default}/bin/zl";
        };
      }
    );
}
