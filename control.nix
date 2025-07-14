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
    snap-target = lib.mkOption {
      type = lib.types.str;
      default = "alsa_input.pci-0000_04_00.6.analog-stereo"; # TODO
      description = ''
        The pipewire output to send to snapserver
      '';
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
                "node.description" = "Alloria RTP Control";
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
        location = lib.getExe' pkgs.pipewire "pw-record";
        query = {
          params = "--target ${cfg.snap-target} -";
        };
      };
    };
  };
}
