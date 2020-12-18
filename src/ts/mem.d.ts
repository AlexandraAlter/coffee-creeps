import type { Level as LogLevel } from './log'
import type { Zone } from './zone'
import type { RobotWorker, PowerRobotWorker } from './worker.robots'
import type { SpawnWorker } from './worker.spawns'

declare global {
  interface Memory {
    sys: SystemMemory
    brain: BrainMemory
    cortexes: { [name: string]: CortexMemory }

    rooms: { [name: string]: RoomMemory }
    nodes: { [name: string]: NodeMemory }
    spawns: { [name: string]: SpawnMemory }
    creeps: { [name: string]: CreepMemory }
    powerCreeps: { [name: string]: PowerCreepMemory }
    flags: { [name: string]: FlagMemory }

    logLevel: LogLevel
    globalBackoff: number
    nodeTtl: number
  }

  interface CoreMemory {
    paused: boolean
    failedOn: number | null
  }

  interface WorkerMemory extends CoreMemory {
    task: string | undefined
    state: object | undefined
  }

  interface SystemMemory extends CoreMemory {}

  interface BrainMemory extends CoreMemory {}

  interface CortexMemory extends CoreMemory {}

  interface CreepMemory extends WorkerMemory {
    role: string
  }

  interface Creep {
    core?: RobotWorker
  }

  interface PowerCreepMemory extends WorkerMemory {
    role: string
  }

  interface PowerCreep {
    core?: PowerRobotWorker
  }

  interface FlagMemory extends CoreMemory {}

  interface RoomMemory extends CoreMemory {}

  interface Room {
    core?: Zone
  }

  interface NodeMemory extends CoreMemory {
    ttl: number
    cls: string
  }

  interface SpawnMemory extends WorkerMemory {}

  interface StructureSpawn {
    core?: SpawnWorker
  }
}
