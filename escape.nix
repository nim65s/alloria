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
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to automatically open ports in the firewall.
      '';
    };
    capture-left = lib.mkOption {
      type = lib.types.str;
      default = "usb-MUSIC-BOOST_USB_Microphone_MB-306-00.mono-fallback:capture_MONO";
    };
    capture-right = lib.mkOption {
      type = lib.types.str;
      default = "usb-MUSIC-BOOST_USB_Microphone_MB-306-00.2.mono-fallback:capture_MONO";
    };
    playback = lib.mkOption {
      type = lib.types.str;
      default = "pci-0000_00_1f.3.analog-stereo";
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
                "node.name" = "rtp-sink-e";
                "node.description" = "Alloria RTP Escape to Control ${cfg.rtp-ip}";
              };
            };
          }
        ];
      };
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
                "node.name" = "rtp-source-e";
                "node.description" = "Alloria RTP Escape from control ${cfg.rtp-ip}";
              };
            };
          }
        ];
      };
    };
    systemd.user.services.alloria-escape-pw-links = {
      description = "Alloria Escape pipewire links";
      wantedBy = [ "default.target" ];
      after = [
        "pipewire.service"
        "pipewire-pulse.service"
      ];
      script = ''
        sleep 5
        ${lib.getExe' pkgs.pipewire "pw-link"} rtp-source-e:receive_FL alsa_output.${cfg.playback}:playback_FL
        ${lib.getExe' pkgs.pipewire "pw-link"} rtp-source-e:receive_FR alsa_output.${cfg.playback}:playback_FR
        ${lib.getExe' pkgs.pipewire "pw-link"} alsa_input.${cfg.capture-left} rtp-sink-e:send_FL
        ${lib.getExe' pkgs.pipewire "pw-link"} alsa_input.${cfg.capture-right} rtp-sink-e:send_FR
      '';
    };
  };
}
