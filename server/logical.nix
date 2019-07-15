# Logical definition of our server
let
  lib = (import <nixpkgs> {}).lib;
in

with import ./common.nix;

overrideFn: # a function of the form (self: super: { ... })
            # to override defaults in default-app-config.nix
let
  appConfig = (import ../default-app-config.nix).extend overrideFn;
in {
  network = {
    inherit (appConfig) enableRollback;
  };

  ${machineName} = { config, pkgs, ... }: {
    imports = [
      ../modules/administrator
      ../modules/helloworld
    ] ++ appConfig.imports;

    networking = {
      hostName = machineName;
      firewall.allowedTCPPorts = [80] ++
        pkgs.lib.optional appConfig.enableHttps 443;
    };

    services = {
      administrator = appConfig.administrator;
      helloworld = appConfig.helloworld.service;
      nginx = {
        enable = true;
        virtualHosts = {
          "_" = {
            default = true;
            locations."/" = {
              # There's a return directive defined in the latest nixpkgs nginx module. Newer channel must be pinned (?)
              extraConfig = ''
                return 404;
              '';
            };
          };

          "${appConfig.helloworld.proxy.host}" = pkgs.lib.mkIf appConfig.helloworld.proxy.enable {
            inherit (appConfig.helloworld.proxy) enableSSL forceSSL;     
            locations."/" = {
              proxyPass = "http://localhost:${toString appConfig.helloworld.service.port}";
            };
          };
        };
      };
    };
  };
}
