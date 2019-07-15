let
  lib = (import <nixpkgs> {}).lib;
in import ./logical.nix (self: super: {
  enableHttps = false;

  helloworld = lib.mergeAttrs super.helloworld {
    proxy = lib.mergeAttrs super.helloworld.proxy {
      host = "helloworld.local";
      enableSSL = false;
      forceSSL = false;
    };
  };
})
