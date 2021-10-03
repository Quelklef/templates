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
      *)  init-template "$@" ;;
    esac
  }

  function fail {
    echo "$@"
    exit 1
  }

  function list-templates {
    echo "Run '${command-name} <template> <new-name>' to clone a template"
    echo "Available templates:"
    for f in $(ls ${here}); do
      if [ -d "${here}/$f" ]; then
        echo "- $f"
      fi
    done
  }

  function init-template {
    local tname="$1"
    local target="${"$"}{2:-$1}"

    [ -d "${here}/$tname" ] || fail "No template '$tname'"
    [ -d "./$target" ] && fail "./$target already exists"

    mkdir -p "./$target" &&
    cp -r "${here}/$tname/." "$target" &&
    chmod -R +wr "./$target" &&
    echo "Cloned to ./$target"
  }

  main "$@"
''
