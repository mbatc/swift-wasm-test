import pyjs
import asyncio

import roboticstoolbox as rtb
import spatialmath as sm
import numpy as np

# def print(x):
#   pyjs.js.console.log(x)

try:
  from swift import Swift
except Exception as e:
  pyjs.js.console.log(e)

from queue import Queue

# Make and instance of the Swift simulator and open it
pyjs.js.console.log("Creating swift instance")
env = Swift()
pyjs.js.console.log("Launching simulator")
env.launch(realtime=True, comms="pyjs")

# pyjs.js.console.log("Creating Panda model")
# panda = rtb.models.Panda()
# panda.q = panda.qr

# pyjs.js.console.log("Initializing target position")
# Tep = panda.fkine(panda.q) * sm.SE3.Tx(0.2) * sm.SE3.Ty(0.2) * sm.SE3.Tz(0.45)

async def run_swift_sim():
    pyjs.js.console.log("Running main")
    
    global panda
    global env
    global Tep

    # pyjs.js.console.log("Adding Panda to swift environment")
    # await env.add(panda)
    # pyjs.js.console.log("Added Panda")

    time_step = 0.05
    arrived = False

    while not arrived:
        pyjs.js.console.log("Still not arrived")

        # Work out the required end-effector velocity to go towards the goal
        # v, arrived = rtb.p_servo(panda.fkine(panda.q), Tep, 1)

        # Set the Panda's joint velocities
        # panda.qd = np.linalg.pinv(panda.jacobe(panda.q)) @ v

        # pyjs.js.console.log(f"panda.qd={panda.qd}")

        # Step the simulator by 50 milliseconds
        await env.step(time_step)

        await asyncio.sleep(time_step)


pyjs.js.console.log("Finished setup")
