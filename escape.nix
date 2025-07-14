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
    rtp-ip = lib.mkOption {
      type = lib.types.str;
    };
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.snapcast
      pkgs.helvum
      pkgs.easyeffects
    ];
    services.pipewire.extraConfig.pipewire = {
      "20-alloria-rtp-sink" = {
        "context.modules" = [
          {
            name = "libpipewire-module-rtp-sink";
            args = {
              "destination.ip" = cfg.rtp-ip;
              "destination.port" = cfg.rtp-port;
              "stream.props" = {
                "media.class" = "Audio/Sink";
                "node.name" = "rtp-sink";
                "node.description" = "Alloria RTP Escape to Control ${cfg.rtp-ip}";
              };
            };
          }
        ];
      };
    };
  };
}
