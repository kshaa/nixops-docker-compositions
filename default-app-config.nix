let
  lib = (import <nixpkgs> {}).lib;
in lib.makeExtensible (self: {
  adminEmail = "admin@example.com";
  enableHttps = true;
  enableRollback = true;

  administrator = {
    enable = true;
    name = "user";
    password = "password";
    # https://github.com/NixOS/nixpkgs/blob/be1c03ddaf867e9a58499cd790d5cd72cffc6fca/nixos/modules/config/users-groups.nix#L9
    # hashedPassword = "";
  };

  helloworld = {
    enable = true;
    host = "helloworld.example.com";
    enableSSL = true;
    forceSSL = true;
  };

  imports = [];
})
