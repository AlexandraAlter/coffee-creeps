import { getLogger } from './log'
import { Freq } from './freq'

import { Worker } from './worker'
import { RobotWorker, PowerRobotWorker } from './worker.robots'
import { SpawnWorker } from './worker.spawns'
import { Role } from './role'

import { Sys as SysCon } from './sys'
import { Cmd as CmdCon } from './cmd'
import _ from 'lodash4'

let logger = getLogger('main')
void logger

export function setupGlobals(): void {
  global.log = require('./log')
  global.freq = require('./freq')
  global.Freq = Freq
  global.Role = Role
  global.Worker = Worker
  global.SpawnWorker = SpawnWorker
  global.RobotWorker = RobotWorker
  global.PowerRobotWorker = PowerRobotWorker
  global.tasks = require('./tasks')
  global.Sys = new SysCon()
  global.getTask = (ref: string) => Sys.tasklib.get(ref)
  global.Cmd = CmdCon()
}

export function loop(): void {
  Freq.Reload.when(() => {
    Sys.reload()
    Freq.finishedReload()
  })
  Sys.clean()
  Sys.linkGame()
  Freq.Rarely.when(() => {
    Sys.refresh()
  })
  Sys.tick()
  Sys.clean()
}
