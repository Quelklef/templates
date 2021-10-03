let

inherit (import ./pins.nix) pkgs purs-nix npmlock2nix gitignoreSource;

nixed = purs-nix.purs
  { srcs = [ ../src ];
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
      [ (nixed.command { srcs = [ ''$(realpath "$PWD/src")'' ]; })
        pkgs.nodejs
      ];

    shellHook = ''
      echo '✨🐈✨'
    '';
  };

}
