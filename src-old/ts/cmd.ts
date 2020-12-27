import { getLogger } from './log'
import _ from 'lodash4'

import type * as utilsMod from './utils'
import type * as logMod from './log'
import type * as backoffMod from './backoff'
import type * as freqMod from './freq'
import type * as memoryMod from './memory'
import type * as rehydratorMod from './rehydrator'

import type * as roleMod from './role'

import type * as tasksMod from './tasks'
import type * as tasksRobotsMod from './tasks.robots'

import type * as casmMod from './casm'
import type * as casmOpcodesMod from './casm.opcodes'
import type * as casmBuildersMod from './casm.builders'

import type * as coreMod from './core'
import type * as workerMod from './worker'
import type * as workerRobotsMod from './worker.robots'
import type * as workerSpawnsMod from './worker.spawns'
import type * as zoneMod from './zone'
import type * as nodeMod from './node'
import type * as cortexMod from './cortex'
import type * as brainMod from './brain'

import type * as sysMod from './sys'
import type * as sysUpkeepMod from './sys.upkeep'
import type * as sysWarMod from './sys.war'
import type * as sysExpansionMod from './sys.expansion'

import type { AnyTask } from './tasks'
import type { Role } from './role'
import type { Core, Backing, AnyCoreBacked } from './core'
import type { AnyWorker } from './worker'
import type { RobotWorker, PowerRobotWorker } from './worker.robots'
import type { SpawnWorker } from './worker.spawns'
import type { Zone } from './zone'

let logger = getLogger('cmd')
void logger

// m: (modules)
//  utils log backoff freq memory rehydrator
//  role
//  tasks t.robots
//  casm c.opcodes c.builders
//  core worker w.robots w.spawns
//  node zone
//  cortex brain
//  sys s.upkeep s.war s.expansion
//  cmd

// cl: (classes)
//  Freq Memory
//  Role
//  Core
//  CoreBacked
//  Worker SpawnWorker RobotWorker PowerRobotWorker
//  Node Zone
//  Cortex Brain
//  Sys
//  Cmd

// s: (searchers)

// c: (commands)
//  test
//  move
//  spawn

// r: (roles)
//  upkeep

export type PosSpec = string
export type PosKind = PosSpec | RoomPosition | _HasRoomPosition
export type ZoneSpec = string | undefined
export type ZoneKind = ZoneSpec | Zone
export type CoreSpec = number | string
export type CoreKind = CoreSpec | Core[] | Core
export type WorkerSpec = number | string
export type WorkerKind = AnyWorker[] | AnyWorker | WorkerSpec
export type AnySpec = PosSpec | ZoneSpec | CoreSpec | WorkerSpec

const posRegex = new RegExp(/([0-9]+)x([0-9]+)(?:@([NWSE0-9]+))?/)

function arrayify<T>(a: Array<T> | T | undefined): Array<T> {
  if (a instanceof Array) {
    return a
  } else if (typeof a === 'undefined') {
    return []
  } else {
    return [a]
  }
}

type Predicate<T> = (val: T) => boolean

export const m = {
  utils: require('./utils') as typeof utilsMod,
  log: require('./log') as typeof logMod,
  backoff: require('./backoff') as typeof backoffMod,
  freq: require('./freq') as typeof freqMod,
  memory: require('./memory') as typeof memoryMod,
  rehydrator: require('./rehydrator') as typeof rehydratorMod,

  role: require('./role') as typeof roleMod,

  tasks: require('./tasks') as typeof tasksMod,
  t: {
    robots: require('./tasks.robots') as typeof tasksRobotsMod,
  },

  casm: require('./casm') as typeof casmMod,
  c: {
    opcodes: require('./casm.opcodes') as typeof casmOpcodesMod,
    builders: require('./casm.builders') as typeof casmBuildersMod,
  },

  core: require('./core') as typeof coreMod,
  worker: require('./worker') as typeof workerMod,
  w: {
    robots: require('./worker.robots') as typeof workerRobotsMod,
    spawns: require('./worker.spawns') as typeof workerSpawnsMod,
  },
  zone: require('./zone') as typeof zoneMod,
  node: require('./node') as typeof nodeMod,
  cortex: require('./cortex') as typeof cortexMod,
  brain: require('./brain') as typeof brainMod,

  sys: require('./sys') as typeof sysMod,
  s: {
    upkeep: require('./sys.upkeep') as typeof sysUpkeepMod,
    war: require('./sys.war') as typeof sysWarMod,
    expansion: require('./sys.expansion') as typeof sysExpansionMod,
  },
}

export const cl = {
  Freq: m.freq.Freq,
  Role: m.role.Role,
  Memory: m.memory.Memory,

  Core: m.core.Core,
  CoreBacked: m.core.CoreBacked,

  Worker: m.worker.Worker,
  SpawnWorker: m.w.spawns.SpawnWorker,
  RobotWorker: m.w.robots.RobotWorker,
  PowerRobotWorker: m.w.robots.PowerRobotWorker,

  Zone: m.zone.Zone,
  Node: m.node.Node,
  Cortex: m.cortex.Cortex,
  Brain: m.brain.Brain,

  Sys: m.sys.SysCls,
}

export const f = {
  id: (id: string): Predicate<any> => (c) => c.id === id,

  named: (name: string): Predicate<any> => (c) => c.name === name,

  core: (c: any): c is Core => c instanceof cl.Core,
  backed: (c: any): c is AnyCoreBacked => c instanceof cl.CoreBacked,
  worker: (c: any): c is AnyWorker => c instanceof cl.Worker,
  robot: (c: any): c is RobotWorker => c instanceof cl.RobotWorker,
  probot: (c: any): c is PowerRobotWorker =>
    c instanceof cl.PowerRobotWorker,
  spawn: (c: any): c is SpawnWorker => c instanceof cl.SpawnWorker,
}

export const a = {
  cores: (): Core[] => [...Sys.workers, ...Sys.zones],

  workers: (): AnyWorker[] => Sys.workers,
  robots: (): RobotWorker[] => _.filter(Sys.workers, f.robot),
  probots: (): PowerRobotWorker[] => _.filter(Sys.workers, f.probot),
  spawns: (): SpawnWorker[] => _.filter(Sys.workers, f.spawn),

  zones: (): Zone[] => Sys.zones,

  tasks: (): AnyTask[] => Sys.tasklib.list(),
}

export const s = {
  id: (id: string): AnyCoreBacked | undefined => {
    const obj = Game.getObjectById(id as Id<Backing<any>>)
    if (!obj) {
      throw Error(`no object with id ${id} found`)
    }
    if (!obj.core) {
      throw Error(`object with id ${id} has no core`)
    }
    return obj.core
  },

  named: (name: string): Core[] => {
    return a.cores().filter(f.named(name))
  },

  group: (name: string): AnyWorker[] => {
    return Sys.getGroup(name) ?? []
  },

  pos: (spec: PosKind): RoomPosition => {
    if (spec instanceof RoomPosition) {
      return spec
    } else if (typeof spec === 'string') {
      const match = posRegex.exec(spec)
      if (!match || match.length < 3) {
        throw Error('invalid pos string')
      }
      const room = match[3] ?? Sys.getCurRoomName()
      if (!room) {
        throw Error('no room provided')
      }
      return new RoomPosition(parseInt(match[1]), parseInt(match[2]), room)
    } else if ('pos' in spec) {
      return spec.pos
    } else {
      throw Error(`bad spec: ${spec}`)
    }
  },

  cores: (spec: CoreKind): Core[] => {
    if (spec instanceof Array || spec instanceof cl.Core) {
      return arrayify(spec)
    } else if (typeof spec === 'string' || typeof spec === 'object') {
      return _.filter(a.cores(), spec)
    } else {
      throw Error(`bad spec: ${spec}`)
    }
  },

  core: (spec: CoreSpec): Core | undefined => _.first(s.cores(spec)),

  workers: (spec: WorkerKind): AnyWorker[] => {
    if (spec instanceof Array || spec instanceof cl.Worker) {
      return arrayify(spec)
    } else if (typeof spec === 'string') {
      return [...s.named(spec).filter(f.worker), ...s.group(spec)]
    } else if (typeof spec === 'number') {
      return s.group(spec.toString())
    } else if (typeof spec === 'object') {
      return _.filter(a.workers(), spec)
    } else {
      throw Error(`bad spec: ${spec}`)
    }
  },

  worker: (spec: WorkerKind): AnyWorker | undefined => {
    return _.first(s.workers(spec))
  },

  robots: (spec: WorkerKind): RobotWorker[] => {
    return _.filter(s.workers(spec), f.robot)
  },

  robot: (spec: WorkerKind): RobotWorker | undefined => {
    return _.first(s.robots(spec))
  },

  probots: (spec: WorkerKind): PowerRobotWorker[] => {
    return _.filter(s.workers(spec), f.probot)
  },

  probot: (spec: WorkerKind): PowerRobotWorker | undefined => {
    return _.first(s.probots(spec))
  },

  spawns: (spec: WorkerKind): SpawnWorker[] => {
    return _.filter(s.workers(spec), f.spawn)
  },

  spawn: (spec: WorkerKind): SpawnWorker | undefined => {
    return _.first(s.spawns(spec))
  },

  zones: (spec: ZoneKind): Zone[] => {
    if (spec instanceof Array || spec instanceof cl.Zone) {
      return arrayify(spec)
    } else if (typeof spec === 'string') {
      return a.zones().filter(f.named(spec))
    } else if (typeof spec === 'object') {
      return _.filter(a.zones(), spec)
    } else if (typeof spec === 'undefined') {
      return arrayify(Sys.getCurZone())
    } else {
      throw Error(`bad spec: ${spec}`)
    }
  },

  zone: (spec: ZoneKind): Zone | undefined => {
    return _.first(s.zones(spec))
  },

  tasks: (spec: CoreSpec): AnyTask[] => {
    if (typeof spec === 'string') {
      const task = Sys.tasklib.get(spec)
      return task ? [task] : []
    } else {
      return _(Sys.tasklib.list()).filter(spec).value()
    }
  },

  task: (spec: CoreSpec): AnyTask | undefined => _.first(s.tasks(spec)),
}

export const c = {
  test: () => {},

  spawn: (who: WorkerKind, what: Role) => {
    const spawners = s.spawns(who)
    for (const spawner of spawners) {
      spawner.spawn(what)
    }
  },

  move: (who: WorkerKind, where: PosKind) => {
    const robots = s.robots(who)
    for (const robot of robots) {
      robot.startTask(m.t.robots.moveTask, {target: s.pos(where)})
    }
  },
}

export const r = {
  upkeep: m.s.upkeep.UpkeepRole,
}
