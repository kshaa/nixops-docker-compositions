{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
}: 

let
  inherit (pkgs.stdenv) mkDerivation;
  inherit (import (builtins.fetchTarball "https://github.com/hercules-ci/gitignore/archive/master.tar.gz") { }) gitignoreSource;
in mkDerivation {
  src = gitignoreSource ./.;
  name = "helloworld";
  description = "Hello World Application";
  installPhase = ''
    mkdir -p $out/
    cp -a * $out/
  '';
}