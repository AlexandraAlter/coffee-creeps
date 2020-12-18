import { getLogger } from './log'
import type { Core } from './core'
import type { Worker } from './worker'
import { RobotWorker, PowerRobotWorker } from './worker.robots'
import { SpawnWorker } from './worker.spawns'
import { Role } from './role'
import _ from 'lodash'

let logger = getLogger('cmd')

type Selector = string | object | Function

export class CmdImpl {
  protected static readonly logger = logger

  allCores() {
    return _([] as Core[]).concat(Sys.workers, Sys.zones)
  }

  allWorkers() {
    return _(Sys.workers as Core[])
  }

  allSpawns() {
    return _(Sys.workers as Core[]).filter({ constructor: SpawnWorker })
  }

  allRobots() {
    return _(Sys.workers as Worker[])
      .filter({ constructor: RobotWorker })
      .concat(_(Sys.workers).filter({ constructor: PowerRobotWorker }))
  }

  allZones() {
    return _(Sys.zones)
  }

  list(sel: Selector) {
    return this.allCores().filter(sel)
  }

  spawn(sel: Selector, role: Role) {
    const spawner = this.allSpawns().find(sel)
    if (!(spawner instanceof SpawnWorker)) {
      throw Error('found object was not a spawner')
    }
    spawner.spawn(role)
  }

  move(sel: Selector, pos: RoomPosition) {
    const robot = this.allRobots().find(sel)
    if (
      !(robot instanceof RobotWorker) &&
      !(robot instanceof PowerRobotWorker)
    ) {
      throw Error(`found object was not a creep: ${robot}`)
    }
    robot.move(pos)
  }
}

export interface CmdCls extends CmdImpl {
  (sel: Selector): Core
}

export function Cmd(): CmdCls {
  const cmd = function (this: CmdImpl, sel: Selector): any {
    return cmd.allCores().filter(sel)
  } as unknown as CmdCls
  Object.setPrototypeOf(cmd, CmdImpl.prototype)
  return cmd
}
