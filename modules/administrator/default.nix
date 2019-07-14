{ lib, pkgs, config, ... }: 
with lib;
let
  cfg = config.services.administrator;
in {
  options.services.administrator = {
    enable = mkEnableOption "Administrator user";
    name = mkOption {
      type = types.string;
      default = "administrator";
    };
    password = mkOption {
      type = types.string;
    };
    hashedPassword = mkOption {
      type =  with types; uniq (nullOr str);
      default = null;
    };
  };

  config = mkIf cfg.enable {
    users.users = {
      "${cfg.name}" = {
        isNormalUser = true;
        createHome = true;
        extraGroups = [ "wheel" ];
        password = cfg.password;
        hashedPassword = cfg.hashedPassword;
      };
    };

    environment.systemPackages = with pkgs; [
      sudo
    ];

    security.sudo.enable = true;
    security.sudo.configFile = ''
      ${cfg.name} ALL = (ALL) ALL
    '';
  };
}
