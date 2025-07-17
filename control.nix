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
    device = lib.mkOption {
      type = lib.types.str;
      default = "pci-0000_04_00.6.analog-stereo";
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
      "20-alloria-netjack2-manager" = {
        "context.modules" = [
          {
            name = "libpipewire-module-netjack2-manager";
            args = {
              "net.ip" = "::";
              "net.port" = 33000;
              "stream.props" = {
                "node.name" = "netjack-manager";
                "node.description" = "Alloria netjack manager";
              };
            };
          }
        ];
      };

      "20-alloria-netjack2-driver" = {
        "context.modules" = [
          {
            name = "libpipewire-module-netjack2-driver";
            args = {
              "net.ip" = "192.168.8.238";
              "net.port" = 33000;
              "stream.props" = {
                "node.name" = "netjack-driver";
                "node.description" = "Alloria netjack driver";
              };
            };
          }
        ];

      };
      # "20-alloria-rtp-sink" = {
      #   "context.modules" = [
      #     {
      #       name = "libpipewire-module-rtp-sink";
      #       args = {
      #         "destination.ip" = cfg.rtp-ip;
      #         "destination.port" = cfg.rtp-port;
      #         "stream.props" = {
      #           "media.class" = "Audio/Sink";
      #           "node.name" = "rtp-sink-r";
      #           "node.description" = "Alloria RTP Control to Escape ${cfg.rtp-ip}";
      #         };
      #       };
      #     }
      #   ];
      # };
      # "20-alloria-rtp-source" = {
      #   "context.modules" = [
      #     {
      #       name = "libpipewire-module-rtp-source";
      #       args = {
      #         "source.ip" = "::";
      #         "source.port" = cfg.rtp-port;
      #         "sess.ignore-ssrc" = true; # so that we can restart the sender
      #         "stream.props" = {
      #           "media.class" = "Audio/Source";
      #           "node.name" = "rtp-source-r";
      #           "node.description" = "Alloria RTP Control from escape ${cfg.rtp-ip}";
      #         };
      #       };
      #     }
      #   ];
      # };
    };
    # systemd.user.services.alloria-control-pw-links = {
    #   description = "Alloria Control pipewire links";
    #   wantedBy = [ "default.target" ];
    #   after = [
    #     "pipewire.service"
    #     "pipewire-pulse.service"
    #   ];
    #   script = ''
    #     sleep 5
    #     ${lib.getExe' pkgs.pipewire "pw-link"} rtp-source-r:receive_FL alsa_output.${cfg.device}:playback_FL
    #     ${lib.getExe' pkgs.pipewire "pw-link"} rtp-source-r:receive_FR alsa_output.${cfg.device}:playback_FR
    #     ${lib.getExe' pkgs.pipewire "pw-link"} alsa_input.${cfg.device}:capture_FL rtp-sink-r:send_FL
    #     ${lib.getExe' pkgs.pipewire "pw-link"} alsa_input.${cfg.device}:capture_FR rtp-sink-r:send_FR
    #   '';
    # };
  };
}
