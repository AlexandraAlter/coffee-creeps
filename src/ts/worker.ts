import { getLogger } from './log'
import { Freq } from './freq'
import { CoreBacked, Backing, newCoreMemory } from './core'
import { Task } from './tasks'
import _ from 'lodash4'

const logger = getLogger('worker')
void logger

export function newWorkerMemory(): WorkerMemory {
  return {
    task: undefined,
    state: undefined,
    ...newCoreMemory(),
  }
}

export abstract class Worker<
  T extends Backing<any>,
  Mem extends WorkerMemory,
> extends CoreBacked<T, Mem> {

  public startTask<A, T extends Task<this, any, A>>(task: T, args: A) {
    Freq.Safety.when(() => {
      if (!(this.sys.tasklib.get(task.name))) {
        throw Error('given a task that is not registered')
      }
    })
    this.memory.task = task.name
    this.memory.state = task.newState(args)
  }

  public stopTask() {
    delete this.memory.task
    delete this.memory.state
  }

  public getTask(): Task<this, any, any> | undefined {
    if (!this.memory.task) {
      return
    }
    return this.sys.tasklib.get(this.memory.task)
  }

  public abstract toRef(): string
}

export type AnyWorker = Worker<any, any>
