let

inherit (import ./pins.nix) pkgs purs-nix npmlock2nix gitignoreSource;

nixed = purs-nix.purs
  { srcs = [ ../app ];
    dependencies =
      with purs-nix.ps-pkgs;
      [ console
        effect
        lists
        maybe
        node-fs
      ];
  };

node_modules = npmlock2nix.node_modules { src = gitignoreSource ./..; };

in {

  deriv = pkgs.stdenv.mkDerivation {
    name = "porygon";
    dontUnpack = true;

    buildInputs = [ pkgs.nodejs ];

    installPhase = ''
      mkdir -p $out

      cp ${nixed.modules.Main.bundle {}} $out/index.js

      if [ -d ${node_modules}/node_modules ]; then
        mkdir -p $out/node_modules/
        cp -r ${node_modules}/node_modules $out/
      fi

      echo "${pkgs.nodejs}/bin/node $out/index.js" > $out/run.sh
      chmod +x $out/run.sh
    '';
  };

  shell = pkgs.mkShell {
    buildInputs =
      [ (nixed.command { srcs = [ ''$(realpath "$PWD/app")'' ]; })
        pkgs.nodejs
        pkgs.python3
        pkgs.entr
      ];

    shellHook = ''

      function workflow.build {(
        echo watching
        find app | entr -s '
          set -eo pipefail
          echo building

          mkdir -p .working
          cd .working

          rm -rf app index.html
          cp -r ../{app,app/index.html} .

          purs-nix bundle
        '
      )}

      function workflow.serve {(
        mkdir -p .working &&
          cd .working &&
          python3 -m http.server
      )}

    '';
  };

}
