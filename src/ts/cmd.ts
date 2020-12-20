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
import type { Core, Backing } from './core'
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
//  move
//  spawn

// r: (roles)
//  upkeep

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

  cmd: module.exports,
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
  Cmd: m.cmd.Cmd,
}

export const a = {
  cores: (): Core[] => [...Sys.workers, ...Sys.zones],

  workers: (): AnyWorker[] => Sys.workers,

  robots: (): RobotWorker[] => {
    return _.filter(
      Sys.workers,
      (w) => w instanceof cl.RobotWorker
    ) as RobotWorker[]
  },

  probots: (): PowerRobotWorker[] => {
    return _.filter(
      Sys.workers,
      (w) => w instanceof cl.PowerRobotWorker
    ) as PowerRobotWorker[]
  },

  spawns: (): SpawnWorker[] => {
    return _.filter(
      Sys.workers,
      (w) => w instanceof cl.SpawnWorker
    ) as SpawnWorker[]
  },

  zones: (): Zone[] => Sys.zones,

  tasks: (): AnyTask[] => Sys.tasklib.list(),
}

export type AnySpec = PosSpec | WorkerSpec
export type PosSpec = RoomPosition
export type CoreSpec = number | string
export type CoreKind = Core[] | Core | number | string
export type WorkerSpec = number | string
export type WorkerKind = AnyWorker[] | AnyWorker | number | string

export const s = {
  id: (id: string): Core | undefined => {
    return (Game.getObjectById(id as Id<Backing<any>>))?.core
  },

  name: (name: string): Core[] => {
    return a.cores().filter((c: any) => c.name === name)
  },

  cores: (spec: CoreSpec): Core[] => {
    return _.filter(a.cores(), spec)
  },

  core: (spec: CoreSpec): Core | undefined => _.first(s.cores(spec)),

  workers: (spec: WorkerSpec): AnyWorker[] => {
    if (typeof spec === 'string') {
      return Sys.getGroup(spec) ?? []
    } else if (typeof spec === 'number') {
      return Sys.getGroup(spec.toString()) ?? []
    } else {
      return _.filter(a.workers(), spec)
    }
  },

  worker: (spec: WorkerSpec): AnyWorker | undefined => {
    return _.first(s.workers(spec))
  },

  robots: (spec: WorkerSpec): RobotWorker[] => {
    return _.filter(s.workers(spec), (w) => w instanceof cl.RobotWorker) as RobotWorker[]
  },

  robot: (spec: WorkerSpec): RobotWorker | undefined => {
    return _.first(s.robots(spec))
  },

  probots: (spec: WorkerSpec): PowerRobotWorker[] => {
    return _.filter(a.probots(), spec)
  },

  probot: (spec: WorkerSpec): PowerRobotWorker | undefined => {
    return _.first(s.probots(spec))
  },

  spawns: (spec: WorkerSpec): SpawnWorker[] => {
    return _.filter(a.spawns(), spec)
  },

  spawn: (spec: WorkerSpec): SpawnWorker | undefined => {
    return _.first(s.spawns(spec))
  },

  zones: (spec: CoreSpec): Zone[] => {
    return _.filter(a.zones(), spec)
  },

  zone: (spec: CoreSpec): Zone | undefined => _.first(s.zones(spec)),

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

  spawn: (who: WorkerSpec, what: Role) => {
    const spawners = s.spawns(who)
    for (const spawner of spawners) {
      spawner.spawn(what)
    }
  },

  move: (who: WorkerSpec, where: RoomPosition) => {
    const robots = s.robots(who)
    for (const robot of robots) {
      robot.move(where)
    }
  },
}

export const r = {
  upkeep: m.s.upkeep.UpkeepRole
}
