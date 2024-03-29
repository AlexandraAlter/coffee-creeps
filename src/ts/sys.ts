import { getLogger } from './log'
import { Limiter } from './limiter'
import { MemProxy } from './memory'
import { Task, TaskInt } from './tasks'
import { Core, CoreMem } from './cores'
import { Cortex, CortexCons, CortexInt } from './cortexes'
import { Role, RoleCons, RoleInt } from './roles'
import { Lib } from './libs'
import _ from 'lodash4'

export class SysMem extends CoreMem {}

export interface Module {
  [index: string]: RoleInt | TaskInt | CortexInt | unknown
}

export class SysCls extends Core<SysMem, never> {
  public readonly modules: Module[]
  public readonly taskLib: Lib<TaskInt>
  public readonly roleLib: Lib<RoleCons>
  public readonly cortexLib: Lib<CortexCons>

  public constructor(modules: Module[]) {
    const limiter = new Limiter('sys')
    const logger = getLogger('sys')
    const memoryProxy = new MemProxy('sys', () => new SysMem())
    super(logger, limiter, memoryProxy)

    this.modules = modules
    this.taskLib = new Lib<TaskInt>()
    this.roleLib = new Lib<RoleCons>()
    this.cortexLib = new Lib<CortexCons>()

    for (const mod of modules) {
      for (const n in mod) {
        const val: unknown = mod[n]
        this.register(val)
      }
    }
  }

  private register(val: Module[string]) {
    if (val instanceof Task) {
      this.taskLib.register(val)
    }

    if (val instanceof Function) {
      if (val.prototype instanceof Role) {
        this.roleLib.register(val as RoleCons)
      }

      if (val.prototype instanceof Cortex) {
        this.cortexLib.register(val as CortexCons)
      }
    }
  }

  //   private typesOf<T extends Function, R extends T>(superType: T): R[] {
  //     return _(this.modules)
  //       .flatMap((m) => _.values(m))
  //       .filter((p) => p.prototype instanceof superType)
  //       .value()
  //   }

  //   public readonly nodeTypes: typeof Node[] = this.typesOf(Node)
  //   public readonly cortexTypes: typeof Cortex[] = this.typesOf(Cortex)

  //   public readonly workers: AnyWorker[] = []
  //   public readonly zones: Zone[] = []
  //   public readonly tasklib = new TaskLib()
  //   public readonly brain = new Brain()

  //   public readonly groups: Map<string, AnyWorker[]> = new Map()
  //   public readonly curZone: Zone | undefined = undefined

  //   public *iterChildren(): Generator<Core<any>> {
  //     for (let worker of this.workers) {
  //       yield worker
  //     }
  //     for (let zone of this.zones) {
  //       yield zone
  //     }
  //     yield this.brain
  //   }

  //   public initMem(): SystemMemory {
  //     return {
  //       groups: {},
  //       ...newCoreMemory(),
  //     }
  //   }

  //   public reload(): void {
  //     this.backoff.withErrRecur(() => {
  //       this.workers.splice(0, this.workers.length)

  //       for (const cName in Game.creeps) {
  //         const creep = Game.creeps[cName]
  //         this.workers.push(new RobotWorker(creep))
  //       }

  //       for (const pName in Game.powerCreeps) {
  //         const powerCreep = Game.powerCreeps[pName]
  //         this.workers.push(new PowerRobotWorker(powerCreep))
  //       }

  //       for (const sName in Game.spawns) {
  //         const spawn = Game.spawns[sName]
  //         this.workers.push(new SpawnWorker(spawn))
  //       }

  //       this.zones.splice(0, this.zones.length)

  //       for (const rName in Game.rooms) {
  //         const room = Game.rooms[rName]
  //         this.zones.push(new Zone(room))
  //       }

  //       registerRobotTasks(this.tasklib)
  //     })
  //   }

  //   // Rooms

  //   public getCurZone(): Zone | undefined {
  //     if (this.curZone) {
  //       return this.curZone
  //     } else if (_.keys(Game.rooms).length === 1) {
  //       return _.values(Game.rooms)[0].core
  //     }
  //   }

  //   public getCurRoomName(): string | undefined {
  //     return this.getCurZone()?.backing.name
  //   }

  //   // Groups

  //   public setGroup(key: string, workers: AnyWorker[]): void {
  //     this.groups.set(key, workers)
  //     this.saveGroup(key)
  //   }

  //   public delGroup(key: string): void {
  //     this.groups.delete(key)
  //     this.saveGroup(key)
  //   }

  //   public getGroup(key: string): AnyWorker[] | undefined {
  //     return this.groups.get(key)
  //   }

  //   public addGroup(key: string, workers: AnyWorker[]): void {
  //     this.getGroup(key)?.push(...workers)
  //     this.saveGroup(key)
  //   }

  //   public remGroup(key: string, workers: AnyWorker[]): void {
  //     const g = this.getGroup(key)
  //     if (g) {
  //       this.setGroup(key, g.filter((w) => !workers.includes(w)))
  //     }
  //     this.saveGroup(key)
  //   }

  //   public saveGroup(key: string): void {
  //     this.memory.groups[key] = this.getGroup(key)?.map((w) => w.toRef())
  //   }

  //   public saveGroups(): void {
  //     this.memory.groups = {}
  //     for (const k in this.groups.keys()) {
  //       this.saveGroup(k)
  //     }
  //   }

  //   public cleanGroups(): void {
  //     for (const group in this.groups.entries()) {
  //       const [k, v] = group
  //       if (_.isEmpty(v)) {
  //         this.groups.delete(k)
  //       }
  //     }
  //     this.saveGroups()
  //   }
}
