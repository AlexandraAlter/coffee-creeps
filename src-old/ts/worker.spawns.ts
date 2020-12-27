import { getLogger } from './log'
import { Core } from './core'
import { newWorkerMemory, Worker } from './worker'
import { RobotWorker } from './worker.robots'
import { Role } from './role'
import _ from 'lodash4'
import {throwScreepsError} from './utils'

const logger = getLogger('worker.spawns')

declare global {
  interface StructureSpawn {
    core?: SpawnWorker
  }
}

@Core.withMemory<SpawnWorker>(function() { return this.memPath })
export class SpawnWorker extends Worker<StructureSpawn, SpawnMemory> {

  protected static logger = logger

  readonly memPath: Array<string>
  readonly name: string

  constructor(ref: StructureSpawn | string) {
    if (typeof ref === 'object') {
      super(ref)
      ref = ref.name
    } else {
      super()
    }
    this.name = ref
    this.memPath = ['spawns', ref]
  }

  public toString() {
    return super.toString().slice(0, -1) + ` ${this.name}]`
  }

  public fetchBacking(): StructureSpawn | undefined {
    const sp = (Game.spawns[this.name] as unknown) as StructureSpawn
    if (!sp) {
      return
    }
    sp.core = this
    return sp
  }

  public initMem(): SpawnMemory {
    return newWorkerMemory()
  }

  public spawn(role: Role) {
    const opts = {maxCost: this.backing.store.energy}
    const parts = role.getParts(opts)
    const name = role.getName(opts)
    const ret = this.backing.spawnCreep(parts, name)
    this.sys.workers.push(new RobotWorker(Game.creeps[name]))
    throwScreepsError(ret)
    return ret
  }

  public recycle(target: RobotWorker) {
    const ret = this.backing.recycleCreep(target.backing)
    throwScreepsError(ret)
    return ret
  }

  public renew(target: RobotWorker) {
    const ret = this.backing.renewCreep(target.backing)
    throwScreepsError(ret)
    return ret
  }

  public toRef(): string {
    return this.backing.id
  }
}
