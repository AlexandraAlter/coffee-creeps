import { getLogger } from './log'
import type { Constructor } from './utils'
import type { Worker, AnyWorker } from './worker'
import _ from 'lodash4'

const logger = getLogger('tasks')

export enum TaskRet {
  OK = 1,
  DONE = 2,
  ABORT = 3,
}

export interface State {}

export interface Task<W extends AnyWorker, S extends State, A> {
  constructor: {
    name: string
  }
}

export abstract class Task<W extends AnyWorker, S extends State, A> {
  protected static logger = logger

  static toString(): string {
    return `[class ${this.name}]`
  }

  constructor(
    readonly ref: string,
    readonly worker: Constructor<W>,
    readonly newState: (args: A) => S
  ) {}

  abstract do(worker: W): TaskRet

  toString(): string {
    return `[${this.constructor.name}]`
  }
}

export type AnyTask = Task<any, any, any>

export class TaskFunc<W extends AnyWorker, S extends State, A> extends Task<
  W,
  S,
  A
> {
  public constructor(
    ref: string,
    worker: Constructor<W>,
    newState: (args: A) => S,
    readonly func: (worker: W, state: S) => TaskRet
  ) {
    super(ref, worker, newState)
  }

  public do(worker: W): TaskRet {
    return this.func(worker, worker.memory.state)
  }
}

export class TaskLib {
  protected static logger = logger

  public static toString(): string {
    return `[class ${this.name}]`
  }

  private tasks: { [index: string]: AnyTask } = {}

  public toString(): string {
    return `[${this.constructor.name}]`
  }

  public register(task: AnyTask) {
    if (task.ref in this.tasks) {
      throw Error(`duplicate task ref ${task.ref} in tasklib`)
    }
    this.tasks[task.ref] = task
  }

  public list(kind?: typeof Worker) {
    const ret = []
    for (const n in this.tasks) {
      const task: AnyTask = this.tasks[n]
      if (task && (!kind || task.worker instanceof kind)) {
        ret.push(task)
      }
    }
    return ret
  }

  public get(ref: string): AnyTask | undefined {
    return this.tasks[ref]
  }
}
