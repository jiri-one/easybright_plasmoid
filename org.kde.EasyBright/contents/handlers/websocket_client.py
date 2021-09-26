#!/usr/bin/env python

import asyncio
import websockets

async def hello():
    async with websockets.connect("ws://localhost:8889") as websocket:
        await websocket.send("0")
        #await websocket.recv()

asyncio.run(hello())
