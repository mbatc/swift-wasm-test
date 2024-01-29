import pyjs
import asyncio

import roboticstoolbox as rtb
import spatialmath as sm
import numpy as np

try:
  from swift import Swift
except Exception as e:
  print(e)

from queue import Queue

# running = True
# def is_running():
#     global running
#     return running
# outq = asyncio.Queue()
# inq = asyncio.Queue()
# swift_comms = TestSwiftPyJS(outq, inq, is_running)
# loop = asyncio.get_running_loop()
# serve_task = loop.create_task(swift_comms.serve())
# print(asyncio.get_running_loop())
# async def main():
#     value = 0.0
#     while is_running():
#         await outq.put([False, ["code", value]])
#         await asyncio.sleep(1)
#         value = value + 1

# Make and instance of the Swift simulator and open it
print("Creating swift instance")
env = Swift()
print("Launching simulator")
env.launch(realtime=True, comms="pyjs")

print("Creating Panda model")
panda = rtb.models.Panda()
panda.q = panda.qr

print("Initializing target position")
Tep = panda.fkine(panda.q) * sm.SE3.Tx(0.2) * sm.SE3.Ty(0.2) * sm.SE3.Tz(0.45)

async def main():
    print("Running main")
    
    global panda
    global env
    global Tep

    print("Adding Panda to swift environment")
    await env.add(panda)
    print("Added Panda")

    time_step = 0.05
    arrived = False

    while not arrived:
        print("Still not arrived")

        # Work out the required end-effector velocity to go towards the goal
        v, arrived = rtb.p_servo(panda.fkine(panda.q), Tep, 1)

        # Set the Panda's joint velocities
        panda.qd = np.linalg.pinv(panda.jacobe(panda.q)) @ v

        print(f"panda.qd={panda.qd}")
        
        # Step the simulator by 50 milliseconds
        await env.step(time_step)

        await asyncio.sleep(time_step)


print("Finished setup")