"""
Manage an escape room
"""

from argparse import Namespace
from asyncio import run, sleep
from logging import getLogger

from aiomqtt import Client, Message, MqttError

from .conf import init, CLIENT_KEYS, PIPEWIRE_KEYS
from .pipewire import Pipewire


logger = getLogger("alloria.escape")


class Alloria:
    def __init__(self, conf: Namespace):
        self.conf = vars(conf)
        self.instance = self.conf["instance"]
        run(self.main())

    async def main(self):
        self.pipewire = Pipewire(**{k: self.conf[k] for k in PIPEWIRE_KEYS})
        self.client = Client(**{k: self.conf[k] for k in CLIENT_KEYS})

        while True:
            try:
                await self.run()
            except MqttError as e:
                logger.error("MQTT Connection failed: %e", e)
                await sleep(5)

    async def run(self):
        logger.info("Connect to MQTT...")
        async with self.client:
            await self.subscribe()
            logger.info("Initialization success")
            async for message in self.client.messages:
                logger.debug("Dispatching %s", message)
                self.dispatch(message)

    async def subscribe(self):
        logger.info("Connected. Subscribing...")
        await self.client.subscribe("alloria/sink")
        await self.client.subscribe("alloria/source")
        await self.client.subscribe("alloria/sink/mute")
        await self.client.subscribe("alloria/source/mute")
        await self.client.subscribe(f"alloria/sink/{self.instance}")
        await self.client.subscribe(f"alloria/source/{self.instance}")
        await self.client.subscribe(f"alloria/sink/mute/{self.instance}")
        await self.client.subscribe(f"alloria/source/mute/{self.instance}")

    def dispatch(self, message: Message):
        topic = message.topic.value
        payload = message.payload.decode()
        device = topic.split("/")[1]
        if "/mute" in topic:
            val = payload if topic.endswith(self.instance) else payload == self.instance
            self.pipewire.mute(device, int(val))
        else:
            self.pipewire.volume(device, float(payload) / 100)


def main():
    conf = init()
    Alloria(conf)


if __name__ == "__main__":
    main()
