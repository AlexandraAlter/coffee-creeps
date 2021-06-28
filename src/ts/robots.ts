import { getLogger } from './log'
import { applyMixins, throwScreepsError } from './utils'
import { Worker, WorkerMem } from './workers'
import { BackingProxy } from './backing'
import { Lib } from './libs'
import { MemProxy } from './memory'
import { Limiter } from './limiter'
import { TaskInt } from './tasks'
import _ from 'lodash4'

const logger = getLogger('robots')

type AnyCreep = Creep | PowerCreep

interface AnyRobotWorker {
  backing: AnyCreep
}

class AnyRobotWorkerMixin {
  move(this: AnyRobotWorker, pos: RoomPosition): ScreepsReturnCode {
    const ret = this.backing.moveTo(pos)
    throwScreepsError(ret)
    return ret
  }
}

export class CreepMemory extends WorkerMem {}

export class RobotWorker extends Worker<CreepMemory, Creep> {
  public static logger = logger

  constructor(readonly name: string, taskLib: Lib<TaskInt>) {
    super(
      new Limiter(name),
      new MemProxy<CreepMemory>(
        ['robots', name],
        () => new CreepMemory()
      ),
      new BackingProxy(
        () => Game.creeps[name],
        () => {}
      ),
      taskLib
    )
    this.name = name
  }

  public toString() {
    return super.toString().slice(0, -1) + ` ${this.name}]`
  }

  public toRef(): string {
    return this.backing?.id ?? ''
  }

  innerReload() {}
  innerClean() {}
  innerRefresh() {}
  innerTick() {}
}
export interface RobotWorker extends AnyRobotWorkerMixin {}
applyMixins(RobotWorker, [AnyRobotWorkerMixin])

export function isRobot(o: any): o is RobotWorker {
  return o instanceof RobotWorker
}

export class PowerCreepMemory extends WorkerMem {}

export class PowerRobotWorker extends Worker<PowerCreepMemory, PowerCreep> {
  public static logger = logger

  constructor(readonly name: string, taskLib: Lib<TaskInt>) {
    super(
      new Limiter(name),
      new MemProxy<PowerCreepMemory>(
        ['robots', name],
        () => new PowerCreepMemory()
      ),
      new BackingProxy(
        () => Game.powerCreeps[name],
        () => {}
      ),
      taskLib
    )
    this.name = name
  }

  public toString() {
    return super.toString().slice(0, -1) + ` ${this.name}]`
  }

  public toRef(): string {
    return this.backing?.name ?? ''
  }

  innerReload() {}
  innerClean() {}
  innerRefresh() {}
  innerTick() {}
}
export interface PowerRobotWorker extends AnyRobotWorkerMixin {}
applyMixins(PowerRobotWorker, [AnyRobotWorkerMixin])

export function isPowerRobot(o: any): o is PowerRobotWorker {
  return o instanceof PowerRobotWorker
}
