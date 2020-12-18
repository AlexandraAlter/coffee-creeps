import { getLogger } from './log'
import { Core, newCoreMemory } from './core'
import { TaskLib } from './tasks'
import { Worker } from './worker'
import { RobotWorker, PowerRobotWorker } from './worker.robots'
import { SpawnWorker } from './worker.spawns'
import { Cortex } from './cortex'
import { Zone } from './zone'
import { Brain } from './brain'
import { registerAll as registerRobotTasks } from './tasks.robots'

let logger = getLogger('sys')

@Core.withMemory('sys')
export class Sys extends Core<SystemMemory> {
  protected static readonly logger = logger

  public readonly modules = {
    upkeep: require('./sys.upkeep'),
    expansion: require('./sys.expansion'),
    war: require('./sys.war'),
  }

  public upkeep = this.modules.upkeep
  public expansion = this.modules.expansion
  public war = this.modules.war

  private typesOf<T extends Function, R extends T>(superType: T): R[] {
    const result: R[] = []
    const modules = this.modules
    for (const mName in modules) {
      const mod: any = this.modules[mName as keyof typeof modules]
      for (const pName in mod) {
        const prop: any = mod[pName]
        if (prop && prop.prototype instanceof superType) {
          result.push(prop)
        }
      }
    }
    return result
  }

  public readonly workerTypes: typeof Worker[] = this.typesOf(Worker)
  public readonly cortexTypes: typeof Cortex[] = this.typesOf(Cortex)

  public readonly workers: Worker<any, any>[] = []
  public readonly zones: Zone[] = []
  public readonly tasklib = new TaskLib()
  public readonly brain = new Brain()

  public *iterChildren(): Generator<Core<any>> {
    for (let worker of this.workers) {
      yield worker
    }
    for (let zone of this.zones) {
      yield zone
    }
    yield this.brain
  }

  public initMem(): SystemMemory {
    return newCoreMemory()
  }

  public reload(): void {
    this.backoff.withErrRecur(() => {
      this.workers.splice(0, this.workers.length)

      for (const cName in Game.creeps) {
        const creep = Game.creeps[cName]
        this.workers.push(new RobotWorker(creep))
      }

      for (const pName in Game.powerCreeps) {
        const powerCreep = Game.powerCreeps[pName]
        this.workers.push(new PowerRobotWorker(powerCreep))
      }

      for (const sName in Game.spawns) {
        const spawn = Game.spawns[sName]
        this.workers.push(new SpawnWorker(spawn))
      }

      this.zones.splice(0, this.zones.length)

      for (const rName in Game.rooms) {
        const room = Game.rooms[rName]
        this.zones.push(new Zone(room))
      }

      registerRobotTasks(this.tasklib)
    })
  }
}
