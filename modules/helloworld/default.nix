{ utils, lib, pkgs, config, ... }: 
with lib;
with builtins;
let
  cfg = config.services.helloworld;
  app = import ./app.nix {};
  composeEnv = with cfg; pkgs.writeText "composeEnv" ''
    STATE_DIR=${stateDirectory}
    PORT=${toString cfg.port}
    HOST=${toString cfg.host}
  '';
  helloworldEnv = with cfg; pkgs.writeText "helloworldEnv" ''
    WORLD=${cfg.recipient}
  '';
  dockerComposeBin = "${pkgs.docker_compose}/bin/docker-compose";
  stateDirectory = "${cfg.workingDirectory}/state";
in {
  # Declare options
  options.services.helloworld = {
    enable = mkEnableOption "Docker-composed, nginx-hosted hello-world web application service";
    user = mkOption {
      type = types.str;
      default = "helloworld";
      description = "Which user will the service run as";
    };
    group = mkOption {
      type = types.str;
      default = "helloworld";
      description = "Which group will the service run as";
    };
    host = mkOption {
      type = types.str;
      default = "0.0.0.0";
      description = "Which host will the service listen to";
    };
    port = mkOption {
      type = types.port;
      default = 8000;
      description = "Which port will the service listen to";
    };
    recipient = mkOption {
      type = types.str;
      default = "World";
      description = "Recipient of the greeting? I.e. Who gets hello'd. I.e. Hello **World**";
    };
    workingDirectory = mkOption {
      type = types.str;
      default = "/var/www/helloworld";
      description = "Where will the composition working directory be.";
    };
    persistentStateDirectory = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Directory which will be linked in the working directory for composition state storage.";
    };
  };

  # Define configuration
  config = mkIf cfg.enable {
    users.groups."${cfg.group}" = {};
    users.users = {
      "${cfg.user}" = {
        group = cfg.group;
        extraGroups = [ "docker" ];
        useDefaultShell = true;
      };
    };

    systemd.services.helloworldPrepare = {
      partOf = [ "network.target" "helloworld.service" ];
      bindsTo = [ "network.target" "helloworld.service" ];
      description = "Preparation helloworld project";
      
      serviceConfig = {
        Group = cfg.group;
      };

      script = ''
        echo "Starting"

        echo "(Re)Creating work directory"
        rm -rf ${cfg.workingDirectory} || true
        mkdir -p ${cfg.workingDirectory}
        cd ${cfg.workingDirectory}

        echo "Copying the project"
        cp -rfT ${app} ./

        ${if cfg.persistentStateDirectory != null then ''
        
        echo "Linking persistent state directory"
        ln -s ${cfg.persistentStateDirectory} ${stateDirectory}        
        
        '' else ''
        
        echo "Creating non-persistent state directory"
        mkdir -p ${stateDirectory}
        
        ''}
        
        echo "Copying configuration files"
        cp -rf ${composeEnv} .env
        cp -rf ${helloworldEnv} .env.helloworld

        echo "Deployed content as follows"
        ls -la
      '';
      preStop = ''
        echo "Stopping"
      ''; 
    };

    systemd.services.helloworld = {
      description = "Docker-composed, nginx-hosted hello-world web app";

      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "helloworldPrepare.service" ];
      partOf = [ "helloworldPrepare.service" ];

      serviceConfig = {
        User = cfg.user;
        Restart = "always";
        WorkingDirectory = cfg.workingDirectory;
        RestartSec = "5";
      };

      script = ''
        echo "Starting at '$(pwd)'"
        echo "With content as follows"
        ls -la

        ${dockerComposeBin} up
      '';

      preStop = ''
        echo "Stopping"
      ''; 
    };

    virtualisation.docker.enable = true;
    environment.systemPackages = with pkgs; [
      docker_compose
    ];
  };
}
