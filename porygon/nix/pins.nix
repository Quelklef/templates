rec {

pkgs = import <nixpkgs> {};

purs-nix =
  let fetched = builtins.fetchGit
       { url = "https://github.com/ursi/purs-nix.git";
         rev = "ef777b08b38e225f1fcb6b4ea3796b450fe2602f";
       };
  in import fetched {};

npmlock2nix =
  let fetched = builtins.fetchGit {
        url = "https://github.com/tweag/npmlock2nix.git";
        rev = "8ada8945e05b215f3fffbd10111f266ea70bb502";
      };
  in import fetched { inherit pkgs; };

gitignoreSource =
  let fetched = builtins.fetchGit {
        url = "https://github.com/hercules-ci/gitignore.nix";
        rev = "80463148cd97eebacf80ba68cf0043598f0d7438";
      };
  in (import fetched { inherit (pkgs) lib; }).gitignoreSource;

}
