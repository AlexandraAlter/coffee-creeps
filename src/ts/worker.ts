import { getLogger } from './log'
import { Freq } from './freq'
import { CoreBacked, Backing, newCoreMemory } from './core'
import { Task } from './tasks'
import _ from 'lodash'

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
  T extends Backing<any> = any,
  Mem extends WorkerMemory = any,
> extends CoreBacked<T, Mem> {

  public startTask(task: Task<this>) {
    Freq.Safety.when(() => {
      if (!(this.sys.tasklib.get(task.toRef()))) {
        throw Error('given a task that is not registered')
      }
    })
    this.memory.task = task.toRef()
    this.memory.state = task.newState()
  }

  public stopTask() {
    delete this.memory.task
    delete this.memory.state
  }

  public getTask(): Task<this> | undefined {
    if (!this.memory.task) {
      return
    }
    return this.sys.tasklib.get(this.memory.task)
  }


}
