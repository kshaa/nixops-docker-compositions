import ./logical.nix (self: super: {
  enableHttps = false;

  helloworld = {
    enable = true;
    host = "helloworld.local";
    enableSSL = false;
    forceSSL = false;
  };
})
