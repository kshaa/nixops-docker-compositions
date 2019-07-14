# Logical definition of our server

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
      helloworld = {
        enable = appConfig.helloworld.enable;
        port = 3000;
      };
      nginx = {
        enable = true;
        virtualHosts = {
          "${appConfig.helloworld.host}" = pkgs.lib.mkIf appConfig.helloworld.enable {
            inherit (appConfig.helloworld) enableSSL forceSSL;     
            locations."/" = {
              proxyPass = "http://localhost:3000";
            };
          };
        };
      };
    };
  };
}
