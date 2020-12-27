import { getLogger } from './log'
import { applyMixins, throwScreepsError } from './utils'
import { Worker, WorkerMem } from './workers'
import _ from 'lodash4'
import { BackingProxy } from './backing'
import { TaskLib } from './tasks'
import { MemProxy } from './memory'
import { Limiter } from './limiter'

const logger = getLogger('worker.robots')

export class CreepMemory extends WorkerMem {}

export class PowerCreepMemory extends WorkerMem {}

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

export class RobotWorker extends Worker<CreepMemory, Creep> {
  public static logger = logger

  constructor(readonly name: string, taskLib: TaskLib) {
    super(
      new Limiter(name),
      new MemProxy<PowerCreepMemory>(
        ['robots', name],
        () => new PowerCreepMemory()
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

  fetchBacking(): Creep | undefined {
    const sp = (Game.creeps[this.name] as unknown) as Creep
    if (!sp) {
      return
    }
    return sp
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

export class PowerRobotWorker extends Worker<PowerCreepMemory, PowerCreep> {
  public static logger = logger

  constructor(readonly name: string, taskLib: TaskLib) {
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
