{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.alloria-control;
in
{
  options.services.alloria-control = {
    enable = lib.mkEnableOption "Alloria Control room service";
    rtp-port = lib.mkOption {
      type = lib.types.port;
      default = 46000;
    };
    rtp-ip = lib.mkOption {
      type = lib.types.str;
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
                "node.description" = "Alloria RTP Control for ${cfg.rtp-ip}";
              };
            };
          }
        ];

      };
    };
    services.snapserver = {
      inherit (cfg) enable openFirewall;
      streams.alloria-control = {
        type = "process";
        location = "process:///${lib.getExe' pkgs.pipewire "pw-record"}?name=alloria-snapserver&params=-";
      };
    };
  };
}
