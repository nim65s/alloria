from argparse import ArgumentParser, Namespace
from logging import basicConfig, getLogger
from os import environ

CLIENT_KEYS = ["hostname", "port", "username", "password"]
PIPEWIRE_KEYS = [
    "device",
    "speaker",
    "microphone",
    "microphone_left",
    "microphone_right",
]


def get_parser() -> ArgumentParser:
    """Configuration flags and environment variables"""

    parser = ArgumentParser()

    # Logging
    parser.add_argument(
        "-q",
        "--quiet",
        action="count",
        default=int(environ.get("QUIET", 0)),
        help="decrement verbosity level",
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="count",
        default=int(environ.get("VERBOSITY", 0)),
        help="increment verbosity level",
    )

    # MQTT Server

    parser.add_argument(
        "--port",
        type=int,
        default=int(environ.get("ALLORIA_PORT", 1883)),
        help="MQTT server port. Default to $ALLORIA_PORT, or 1883",
    )
    parser.add_argument(
        "--hostname",
        default=environ.get("ALLORIA_HOSTNAME", "alloria-control"),
        help="MQTT server hostname. Default to $ALLORIA_HOSTNAME, or 'alloria-control'",
    )
    parser.add_argument(
        "--username",
        default=environ.get("ALLORIA_USERNAME", "alloria"),
        help="MQTT username. Default to $ALLORIA_USER, or 'alloria'",
    )
    parser.add_argument(
        "--password",
        default=environ.get("ALLORIA_PASSWORD"),
        help="MQTT username. Default to $ALLORIA_PASSWORD",
    )

    # Pipewire
    parser.add_argument(
        "--device",
        default=environ.get("ALLORIA_DEVICE"),
        help="alsa device for all mic & spk. Default to $ALLORIA_DEVICE",
    )
    parser.add_argument(
        "--speaker",
        default=environ.get("ALLORIA_SPEAKER"),
        help="alsa device for speaker. Default to $ALLORIA_SPEAKER",
    )
    parser.add_argument(
        "--microphone",
        default=environ.get("ALLORIA_MICROPHONE"),
        help="alsa device for microphone. Default to $ALLORIA_MICROPHONE",
    )
    parser.add_argument(
        "--microphone-left",
        default=environ.get("ALLORIA_MICROPHONE_LEFT"),
        help="alsa device for left microphone. Default to $ALLORIA_MICROPHONE_LEFT",
    )
    parser.add_argument(
        "--microphone-right",
        default=environ.get("ALLORIA_MICROPHONE_RIGHT"),
        help="alsa device for right microphone. Default to $ALLORIA_MICROPHONE_RIGHT",
    )

    # Escape
    parser.add_argument(
        "--instance",
        default=environ.get("ALLORIA_INSTANCE", "room1-1"),
        help="Escape room instance. Default to $ALLORIA_INSTANCE, or 'room1-1'",
    )

    return parser


def init(parser: ArgumentParser | None = None) -> Namespace:
    parser = parser or get_parser()
    args = parser.parse_args()
    basicConfig(level=30 - 10 * args.verbose + 10 * args.quiet)
    return args


if __name__ == "__main__":
    conf = init()
    logger = getLogger("alloria.conf")
    logger.critical("critical messages are shown")
    logger.error("error messages are shown")
    logger.warning("warning messages are shown")
    logger.info("info messages are shown")
    logger.debug("debug messages are shown")
    print(f"{conf=}")
