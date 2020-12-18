import { getLogger } from './log'
import { applyMixins } from './utils'
import { Core } from './core'
import { Worker, newWorkerMemory } from './worker'
import _ from 'lodash'

const logger = getLogger('worker.robots')

export function newCreepMemory(): CreepMemory {
  return {
    role: 'unknown',
    ...newWorkerMemory(),
  }
}

export function newPowerCreepMemory(): PowerCreepMemory {
  return {
    role: 'unknown',
    ...newWorkerMemory(),
  }
}

type AnyCreep = Creep | PowerCreep

interface AnyRobotWorker {
  backing: AnyCreep
}

class AnyRobotWorkerMixin {
  move(this: AnyRobotWorker, pos: RoomPosition): ScreepsReturnCode {
    return this.backing.moveTo(pos)
  }
}


@Core.withMemory<RobotWorker>(function() { return this.memPath })
export class RobotWorker extends Worker<Creep, CreepMemory> {

  protected static logger = logger

  readonly memPath: Array<string>
  readonly name: string

  constructor(ref: Creep | string) {
    if (typeof ref === 'object') {
      super(ref)
      ref = ref.name
    } else {
      super()
    }
    this.name = ref
    this.memPath = ['robots', ref]
  }

  public toString() {
    return super.toString().slice(0, -1) + ` ${this.name}]`
  }

  fetchBacking(): Creep | undefined {
    const sp = (Game.creeps[this.name] as unknown) as Creep
    if (!sp) {
      return
    }
    sp.core = this
    return sp
  }

  initMem(): CreepMemory {
    return newCreepMemory()
  }
}
export interface RobotWorker extends AnyRobotWorkerMixin {}
applyMixins(RobotWorker, [AnyRobotWorkerMixin])


@Core.withMemory<PowerRobotWorker>(function() { return this.memPath })
export class PowerRobotWorker extends Worker<PowerCreep, PowerCreepMemory> {

  protected static logger = logger

  readonly memPath: Array<string>
  readonly name: string

  constructor(ref: PowerCreep | string) {
    if (typeof ref === 'object') {
      super(ref)
      ref = ref.name
    } else {
      super()
    }
    this.name = ref
    this.memPath = ['robots', ref]
  }

  public toString() {
    return super.toString().slice(0, -1) + ` ${this.name}]`
  }

  fetchBacking(): PowerCreep | undefined {
    const sp = (Game.creeps[this.name] as unknown) as PowerCreep
    if (!sp) {
      return
    }
    sp.core = this
    return sp
  }

  initMem(): PowerCreepMemory {
    return newPowerCreepMemory()
  }
}
export interface PowerRobotWorker extends AnyRobotWorkerMixin {}
applyMixins(PowerRobotWorker, [AnyRobotWorkerMixin])
