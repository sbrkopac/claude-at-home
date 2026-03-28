{
  description = "Claude at Home — Mom said we have Claude Code at home.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        claude-at-home = pkgs.stdenv.mkDerivation {
          pname = "claude-at-home";
          version = "2.0.61-athome.1";
          src = ./.;

          nativeBuildInputs = [ pkgs.makeWrapper ];
          buildInputs = [ pkgs.nodejs_22 ];

          installPhase = ''
            mkdir -p $out/lib/claude-at-home
            cp cli.js package.json sdk-tools.d.ts $out/lib/claude-at-home/
            cp tree-sitter-bash.wasm tree-sitter.wasm $out/lib/claude-at-home/
            if [ -d vendor ]; then
              cp -r vendor $out/lib/claude-at-home/
            fi

            mkdir -p $out/bin
            makeWrapper ${pkgs.nodejs_22}/bin/node $out/bin/claude-at-home \
              --add-flags "--no-warnings --enable-source-maps $out/lib/claude-at-home/cli.js" \
              --set NODE_PATH "$out/lib/claude-at-home" \
              --set DISABLE_AUTOUPDATER "1"
          '';
        };
      in
      {
        packages = {
          default = claude-at-home;
          claude-at-home = claude-at-home;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [ pkgs.nodejs_22 pkgs.bc ];
        };
      }
    );
}
