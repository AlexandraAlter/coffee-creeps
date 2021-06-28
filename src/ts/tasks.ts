import { getLogger, Logger } from './log'
import type { WorkerInt } from './workers'
import { Refable } from './libs'
import _ from 'lodash4'

const logger = getLogger('tasks')

export enum TaskRet {
  OK = 1,
  DONE = 2,
  ABORT = 3,
}

export interface TaskMem {
  mode: TaskMode
  task: string | undefined
  state: object | undefined
  queue: Array<string> | undefined
}

export interface TaskInt extends Refable {
  ref: string
  kind: WorkerConstructor
  start: (worker: any, args: any) => void
  step: (worker: any) => TaskRet
  stop: (worker: any) => void
  constructor: TaskConstructor
}

export interface TaskConstructor extends Function {
  name: string
  logger: Logger
}

export interface Task<W extends WorkerInt, S extends object, A> {
  constructor: TaskConstructor
}

export abstract class Task<W extends WorkerInt, S extends object, A>
  implements TaskInt {
  static toString(): string {
    return `[class ${this.name}]`
  }

  public static logger = logger

  constructor(
    readonly ref: string,
    readonly kind: WorkerConstructor,
    readonly newState: (args: A) => S
  ) {}

  toString(): string {
    return `[${this.constructor.name}]`
  }

  public start(worker: W, args: A): void {
    worker.memory.state = this.newState(args) as object
  }

  abstract step(worker: W): TaskRet

  public stop(worker: W): void {
    worker.memory.task = undefined
    worker.memory.state = undefined
  }
}

export class TaskFunc<
  W extends WorkerInt,
  S extends object,
  A
> extends Task<W, S, A> {
  public constructor(
    ref: string,
    worker: WorkerConstructor,
    newState: (args: A) => S,
    readonly func: (worker: W, state: S) => TaskRet
  ) {
    super(ref, worker, newState)
  }

  public step(worker: W): TaskRet {
    return this.func(worker, worker.memory.state as S)
  }
}

// export class TaskLib {
//   public static toString(): string {
//     return `[class ${this.name}]`
//   }

//   protected static logger = logger

//   private tasks: { [index: string]: TaskInt | undefined } = {}

//   public toString(): string {
//     return `[${this.constructor.name}]`
//   }

//   public register(task: TaskInt) {
//     if (task.ref in this.tasks) {
//       throw Error(`duplicate task ref ${task.ref} in tasklib`)
//     }
//     this.tasks[task.ref] = task
//   }

//   public list(kind?: WorkerConstructor) {
//     const ret = []
//     for (const n in this.tasks) {
//       const task = this.tasks[n]
//       if (task && (!kind || task.worker instanceof kind)) {
//         ret.push(task)
//       }
//     }
//     return ret
//   }

//   public get(ref: string, kind?: WorkerConstructor): TaskInt | undefined {
//     const task = this.tasks[ref]
//     if (!task) {
//       throw Error(`no task found for ${ref}`)
//     }
//     if (kind && !(task.worker instanceof kind)) {
//       throw Error(
//         `found task for ${ref} is for ${task.worker}, not ${kind}`
//       )
//     }
//     return task
//   }
// }
