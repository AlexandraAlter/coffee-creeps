import { getLogger, Logger } from './log'
import type { Constructor } from './utils'
import type { Worker } from './worker'
import _ from 'lodash'

const logger = getLogger('tasks')

export enum TaskRet {
  OK = 1,
  DONE = 2,
}

export interface State {}

export interface Task<W extends Worker = any, S extends State = any> {
  constructor: {
    name: string
  }
}

export abstract class Task<
  W extends Worker = any,
  S extends State = any,
  A extends object = object
> {
  protected static logger = logger

  static toRef(): string {
    return this.name
  }

  static toString(): string {
    return `[class ${this.name}]`
  }

  constructor(
    readonly name: string,
    readonly worker: Constructor<W>,
    readonly newState: (args: A) => S
  ) {}

  toString(): string {
    return `[${this.constructor.name}]`
  }
}

export class TaskFunc<
  W extends Worker = any,
  S extends State = any,
  A extends object = object
> extends Task<W, S, A> {
  public constructor(
    name: string,
    worker: Constructor<W>,
    newState: (args: A) => S,
    readonly func: (worker: W, state: S) => TaskRet
  ) {
    super(name, worker, newState)
  }
}

export class TaskLib {
  protected static logger = logger

  public static toString(): string {
    return `[class ${this.name}]`
  }

  private tasks: { [index: string]: Task } = {}

  public toString(): string {
    return `[${this.constructor.name}]`
  }

  public register(task: Task) {
    if (task.name in this.tasks) {
      throw Error(`duplicate task name ${task.name} in tasklib`)
    }
    this.tasks[task.name] = task
  }

  public list(kind?: typeof Worker) {
    const ret = []
    for (const n in this.tasks) {
      const task: Task = this.tasks[n]
      if (task && (!kind || task.worker instanceof kind)) {
        ret.push(task)
      }
    }
    return ret
  }

  public get(name: string): Task | undefined {
    return this.tasks[name]
  }
}
