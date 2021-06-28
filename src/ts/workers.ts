import { Logger } from './log'
import { Freq } from './freq'
import { Core, CoreInt, CoreMem } from './cores'
import type { BackingProxy } from './backing'
import type { MemProxy } from './memory'
import type { Limiter } from './limiter'
import { Task, TaskInt, TaskMem } from './tasks'
import { Lib } from './libs'
import _ from 'lodash4'

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

export interface WorkerInt extends CoreInt {
  memory: WorkerMem
}

export abstract class Worker<M extends WorkerMem, B> extends Core<M, B> {
  public readonly taskLib: Lib<TaskInt>

  constructor(
    logger: Logger,
    limiter: Limiter,
    memoryProxy: MemProxy<M>,
    backingProxy: B extends void ? undefined : BackingProxy<B>,
    taskLib: Lib<TaskInt>
  ) {
    super(logger, limiter, memoryProxy, backingProxy)
    this.taskLib = taskLib
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

export function isWorker(o: any): o is Worker<any, any> {
  return o instanceof Worker
}
