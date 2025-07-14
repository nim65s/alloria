{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.alloria-escape;
in
{
  options.services.alloria-escape = {
    enable = lib.mkEnableOption "Alloria Escape room service";
    rtp-port = lib.mkOption {
      type = lib.types.port;
      default = 46000;
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to automatically open ports in the firewall.
      '';
    };

  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.snapcast
      pkgs.helvum
      pkgs.easyeffects
    ];
    networking.firewall.allowedUDPPorts = lib.optionals cfg.openFirewall [ cfg.rtp-port ];
    services.pipewire.extraConfig.pipewire = {
      "20-alloria-rtp-source" = {
        "context.modules" = [
          {
            name = "libpipewire-module-rtp-source";
            args = {
              "source.ip" = "::";
              "source.port" = cfg.rtp-port;
              "sess.ignore-ssrc" = true; # so that we can restart the sender
              "stream.props" = {
                "media.class" = "Audio/Source";
                "node.name" = "rtp-source";
                "node.description" = "Alloria RTP Escape";
              };
            };
          }
        ];
      };
    };
  };
}
