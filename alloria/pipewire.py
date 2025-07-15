from json import loads
from logging import getLogger
from subprocess import check_call, check_output

logger = getLogger("alloria.pipewire")


class Pipewire:
    def __init__(
        self,
        device: str | None = None,
        speaker: str | None = None,
        microphone: str | None = None,
        microphone_left: str | None = None,
        microphone_right: str | None = None,
    ):
        if device is not None:
            self.speaker_left = f"{device}:playback_FL"
            self.speaker_right = f"{device}:playback_FR"
            self.microphone_left = f"{device}:capture_FL"
            self.microphone_right = f"{device}:capture_FR"
            self.managed = [device]
        else:
            self.speaker_left = f"{speaker}:playback_FL"
            self.speaker_right = f"{speaker}:playback_FR"
            if microphone is not None:
                self.microphone_left = f"{microphone}:capture_FL"
                self.microphone_right = f"{microphone}:capture_FR"
                self.managed = [speaker, microphone]
            else:
                self.microphone_left = microphone_left
                self.microphone_right = microphone_right
                self.managed = [speaker, microphone_left, microphone_right]

        # self.set_links()

    def set_links(self):
        for output, input in [
            ("rtp-source:receive_FL", f"alsa_output.{self.speaker_left}"),
            ("rtp-source:receive_FR", f"alsa_output.{self.speaker_right}"),
            (f"alsa_input.{self.microphone_left}", "rtp-sink:send_FL"),
            (f"alsa_input.{self.microphone_right}", "rtp-sink:send_FR"),
        ]:
            cmd = f"pw-link {output} {input}"
            logger.debug("Spawning '%s'", cmd)
            check_call(cmd.split())

    def ids(self, device: str):
        logger.debug("Looking for %s in wpctl %s", self.managed, device)
        ids = []
        section = False
        start = f" ├─ {device.title()}s:"
        end = " │  "
        for line in check_output(["wpctl", "status", "-n"], text=True).split("\n"):
            if not section:
                section = line == start
                continue
            if line == end:
                return ids
            if any(m in line for m in self.managed):
                ids.append(int(line.split(".")[0].split()[-1]))

    def mute(self, device: str, val: int):
        for id in self.ids(device):
            cmd = f"wpctl set-mute {id} {val}"
            logger.debug("Spawning '%s'", cmd)
            check_call(cmd.split())

    def volume(self, device: str, val: float):
        for id in self.ids(device):
            cmd = f"wpctl set-volume {id} {val}"
            logger.debug("Spawning '%s'", cmd)
            check_call(cmd.split())
