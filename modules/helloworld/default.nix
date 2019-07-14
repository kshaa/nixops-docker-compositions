{ lib, pkgs, config, ... }: 
with lib;
with builtins;
let
  cfg = config.services.helloworld;
  app = import ./app.nix {};
  docker_compose_bin = "${pkgs.docker_compose}/bin/docker-compose";
in {
  # Declare options
  options.services.helloworld = {
    enable = mkEnableOption "Docker-composed, nginx-hosted hello-world web application service";
    user = mkOption {
      type = types.str;
      default = "helloworld";
      description = "Which user will the service run as";
    };
    port = mkOption {
      type = types.int;
      default = 3000;
      description = "Which port will the service bind to";
    };
    recipient = mkOption {
      type = types.str;
      default = "World";
      description = "Recipient of the greeting? I.e. Who gets hello'd. I.e. Hello **World**";
    };
  };

  # Define configuration
  config = mkIf cfg.enable {
    users.extraUsers = {
      "${cfg.user}" = {
        extraGroups = [ "docker" ];
      };
    };

    systemd.services.helloworld = {
      description = "Docker-composed, nginx-hosted hello-world web app";

      # Auto-start somewhere within Systemd run-levels 2. - 4.
      wantedBy = [ "multi-user.target" ];
      
      # Start the service after the network is available
      after = [ "network.target" ];

      serviceConfig = {
        User = "${cfg.user}";
        Restart = "always";
      };

      script = ''
        echo "Starting"
        cd ${app}
        ${docker_compose_bin} up -d
      '';

      preStop = ''
        echo "Stopping"
        cd ${app}
        ${docker_compose_bin} up -d
      ''; 
    };

    virtualisation.docker.enable = true;
    environment.systemPackages = with pkgs; [
      docker_compose
    ];
  };
}
