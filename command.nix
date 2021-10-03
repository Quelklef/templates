{ pkgs ? import <nixpkgs> {}
, command-name ? "q.init-template"
}:

let

gitignoreSource =
  let fetched = builtins.fetchGit {
        url = "https://github.com/hercules-ci/gitignore.nix";
        rev = "80463148cd97eebacf80ba68cf0043598f0d7438";
      };
  in (import fetched { inherit (pkgs) lib; }).gitignoreSource;

here = gitignoreSource ./.;

in

pkgs.writeShellScriptBin command-name ''
  function main {
    case "$#" in
      0)  list-templates ;;
      1)  init-template "$1" ;;
      *)  fail 'Expected 0 or 1 commands' ;;
    esac
  }

  function fail {
    echo "$@"
    exit 1
  }

  function list-templates {
    echo "Run '${command-name} <template>' to clone a template"
    echo "Available templates:"
    for f in $(ls ${here}); do
      if [ -d "${here}/$f" ]; then
        echo "- $f"
      fi
    done
  }

  function init-template {
    local tname="$1"

    [ -d "${here}/$tname" ] || fail "No template '$tname'"
    [ -d "./$tname" ] && fail "./$tname already exists"

    mkdir -p "./$tname" &&
    cp -r "${here}/$tname/." "./$tname" &&
    chmod -R +wr "./$tname" &&
    echo "Initialized to ./$tname"
  }

  main "$@"
''
