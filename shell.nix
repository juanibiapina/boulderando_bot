{ pkgs ? import <nixpkgs> {} }:

let
  pwd = builtins.getEnv "PWD";
  ruby_version_string = builtins.readFile (pwd + "/.ruby-version");
  ruby_version_parts = builtins.match "([0-9]*)\.([0-9]*)\..*" ruby_version_string;
  ruby_package = builtins.concatStringsSep "_" (["ruby"] ++ ruby_version_parts);
in
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    pkgs.${ruby_package}
  ];
  shellHook = ''
    # install gems locally
    mkdir -p .local/nix-gems
    export GEM_HOME=$PWD/.local/nix-gems
    export GEM_PATH=$GEM_HOME
    export PATH=$GEM_HOME/bin:$PATH

    # add local bin directory to path
    export PATH=$PWD/bin:$PATH
  '';
}
