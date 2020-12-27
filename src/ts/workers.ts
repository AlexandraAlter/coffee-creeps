import { getLogger, Logger } from './log'
import { Freq } from './freq'
import { Core, CoreInt, CoreMem } from './core'
import type { BackingProxy } from './backing'
import type { MemProxy } from './memory'
import type { Limiter } from './limiter'
import { Task, TaskInt, TaskLib, TaskMem } from './tasks'
import _ from 'lodash4'

const logger = getLogger('worker')

export class WorkerMem extends CoreMem implements TaskMem {
  mode: TaskMode
  task: string | undefined
  state: object | undefined
  queue: Array<string> | undefined

  constructor() {
    super()
    this.mode = undefined
    this.task = undefined
    this.state = undefined
    this.queue = undefined
  }
}

export interface WorkerConstructor extends Function {
  name: string
  logger: Logger
}

export interface WorkerInt extends CoreInt {
  memory: WorkerMem
  constructor: WorkerConstructor
}

export interface Worker<M extends WorkerMem, B> {
  constructor: WorkerConstructor
}

export abstract class Worker<M extends WorkerMem, B> extends Core<M, B> {
  public static logger = logger

  constructor(
    limiter: Limiter,
    memoryProxy: MemProxy<M>,
    backingProxy: B extends void ? undefined : BackingProxy<B>,
    readonly taskLib: TaskLib
  ) {
    super(limiter, memoryProxy, backingProxy)
  }

  public startTask<A, T extends Task<this, any, A>>(task: T, args: A) {
    Freq.Safety.when(() => {
      if (!this.taskLib.get(task.ref)) {
        throw Error('given a task that is not registered')
      }
    })
    this.memory.task = task.ref
    this.memory.state = task.newState(args)
  }

  public stopTask() {
    delete this.memory.task
    delete this.memory.state
  }

  public getTask(): TaskInt | undefined {
    if (!this.memory.task) {
      return
    }
    return this.taskLib.get(this.memory.task)
  }

  public abstract toRef(): string

  public tick() {
    if (!this.memory.task && this.memory?.mode === 'auto') {
      // find new task
    } else if (this.memory.task) {
      try {
        const t = this.taskLib.get(this.memory.task, this.constructor)
        t!.step(this)
      } catch (e) {
        delete this.memory.task
        delete this.memory.state
        throw e
      }
    }
  }

}
