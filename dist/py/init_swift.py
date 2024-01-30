import pyjs
import asyncio

import roboticstoolbox as rtb
import spatialmath as sm
import numpy as np
import traceback

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

pyjs.js.console.log("Finished setup")
