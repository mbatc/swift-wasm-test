
async def run_sim():
  pyjs.js.console.log("Creating Panda model")
  panda = Panda()
  panda.q = panda.qr

  pyjs.js.console.log("Initializing target position")
  Tep = panda.fkine(panda.q) * sm.SE3.Tx(0.2) * sm.SE3.Ty(0.2) * sm.SE3.Tz(0.45)

  pyjs.js.console.log("Adding Panda to swift environment")
  await env.add(panda)
  pyjs.js.console.log("Added Panda")

  time_step = 0.05
  arrived = False

  while not arrived:
    pyjs.js.console.log("Still not arrived")

    # Work out the required end-effector velocity to go towards the goal
    v, arrived = rtb.p_servo(panda.fkine(panda.q), Tep, 1)

    # Set the Panda's joint velocities
    panda.qd = np.linalg.pinv(panda.jacobe(panda.q)) @ v

    pyjs.js.console.log(f"panda.qd={panda.qd}")

    # Step the simulator by 50 milliseconds
    try:
      await env.step(time_step)
    except Exception as e:
      msg = ''.join(traceback.format_exception(e))
      pyjs.js.console.log(f'Exception occured in env.step: {msg}')

    await asyncio.sleep(time_step)

asyncio.create_task(run_sim())
