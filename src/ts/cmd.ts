import { isBrain } from './brains'
import { isCore } from './cores'
import { isCortex } from './cortexes'
import { isPowerRobot, isRobot } from './robots'
import { isSpawner } from './spawners'
import { isWorker } from './workers'

export const f = {
  core: isCore,

  worker: isWorker,
  robot: isRobot,
  probot: isPowerRobot,
  spawn: isSpawner,

  cortex: isCortex,
  brain: isBrain,
}
