{
  description = "diet-claude - Claude Code on a diet. Minimal token usage, maximum effectiveness.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        diet-claude = pkgs.stdenv.mkDerivation {
          pname = "diet-claude";
          version = "2.0.61";
          src = ./.;

          nativeBuildInputs = [ pkgs.makeWrapper ];
          buildInputs = [ pkgs.nodejs_22 ];

          installPhase = ''
            mkdir -p $out/lib/diet-claude
            cp cli.js package.json sdk-tools.d.ts $out/lib/diet-claude/
            cp tree-sitter-bash.wasm tree-sitter.wasm $out/lib/diet-claude/
            if [ -d vendor ]; then
              cp -r vendor $out/lib/diet-claude/
            fi

            mkdir -p $out/bin
            makeWrapper ${pkgs.nodejs_22}/bin/node $out/bin/diet-claude \
              --add-flags "--no-warnings --enable-source-maps $out/lib/diet-claude/cli.js" \
              --set NODE_PATH "$out/lib/diet-claude" \
              --set DISABLE_AUTOUPDATER "1"
          '';
        };
      in
      {
        packages = {
          default = diet-claude;
          diet-claude = diet-claude;
        };

        apps.default = {
          type = "app";
          program = "${diet-claude}/bin/diet-claude";
        };
      }
    );
}
