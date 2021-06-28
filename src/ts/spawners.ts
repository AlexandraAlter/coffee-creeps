import { getLogger } from './log'
import { Worker, WorkerMem } from './workers'
import { BackingProxy } from './backing'
import { Lib } from './libs'
import { MemProxy } from './memory'
import { Limiter } from './limiter'
import { Role } from './roles'
import _ from 'lodash4'
import {TaskInt} from './tasks'

const logger = getLogger('spawners')

export class SpawnMemory extends WorkerMem {}

export class SpawnWorker extends Worker<SpawnMemory, StructureSpawn> {
  public static logger = logger

  constructor(readonly name: string, taskLib: Lib<TaskInt>) {
    super(
      new Limiter(name),
      new MemProxy<SpawnMemory>(['spawns', name], () => new SpawnMemory()),
      new BackingProxy(
        () => Game.spawns[name],
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

  spawn(role: Role) {
    void role
  }
}

export function isSpawner(o: any): o is SpawnWorker {
  return o instanceof SpawnWorker
}
