import type * as log from './log'
import type { Freq } from './freq'
import type * as freq from './freq'
import type * as tasks from './tasks'

import { Worker } from './worker'
import { RobotWorker, PowerRobotWorker } from './worker.robots'
import { SpawnWorker } from './worker.spawns'
import { Role } from './role'

import type { Sys } from './sys'
import type { CmdCls } from './cmd'

declare global {
  namespace NodeJS {
    export interface Global {
      log: typeof log
      freq: typeof freq
      Freq: typeof Freq
      // roles
      Role: typeof Role
      // workers
      Worker: typeof Worker
      SpawnWorker: typeof SpawnWorker
      RobotWorker: typeof RobotWorker
      PowerRobotWorker: typeof PowerRobotWorker
      // tasks
      tasks: typeof tasks
      getTask: (ref: string) => tasks.Task | undefined
      // nodes
      // cortexes
      // control
      Sys: Sys
      Cmd: CmdCls
    }
  }

  export var Sys: Sys
  export var Cmd: CmdCls
}
