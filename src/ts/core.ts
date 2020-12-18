import { getLogger } from './log'
import type { Logger } from './log'
import _ from 'lodash'
import { Backoff, BackoffMem } from './backoff'

const logger = getLogger('core')

export interface MemInt extends BackoffMem {}

export interface MemConstructor {
  new (): MemInt
}

export function newCoreMemory() {
  return {
    paused: false,
    failedOn: null,
  }
}

type PropKind = (string | number)[] | string
type PropFuncKind<T> = PropKind | ((this: T) => PropKind)

export interface Core {
  constructor: {
    name: string
    logger: Logger
  }
}

export abstract class Core<Mem extends MemInt = CoreMemory> {
  public static toString(): string {
    return `[class ${this.name}]`
  }

  protected static logger = logger

  protected static withMemory<T>(prop: PropFuncKind<T>) {
    var getPath: (this: T) => string | Array<string | number>
    if (typeof prop === 'string') {
      getPath = () => prop
    } else if (typeof prop === 'function') {
      getPath = prop
    } else if (prop instanceof Array) {
      getPath = () => prop
    }

    return function (constructor: Function & {prototype: T}) {
      Object.defineProperty(constructor.prototype, '_memory', {
        enumerable: false,
        writable: true,
        value: null,
      })

      Object.defineProperty(constructor.prototype, 'memory', {
        get: function getMemory() {
          if (this._memory) {
            return this._memory
          }
          const path = getPath.call(this)
          if (typeof path === 'undefined') {
            throw Error('undefined memory path')
          }
          let mem = _.get(Memory, path)
          if (typeof mem === 'undefined') {
            mem = this.initMem()
            _.set(Memory, path, mem)
          }
          return mem
        },

        set: function setMemory(val) {
          const path = getPath.call(this)
          if (typeof path === 'undefined') {
            throw Error('undefined memory path')
          }
          _.set(Memory, path, (this._memory = val))
        },
      })
    }
  }

  protected _memory: Mem | null | undefined = null
  protected readonly backoff: Backoff<Core> = new Backoff(this)

  constructor() {}

  public toString(): string {
    return `[${this.constructor.name}]`
  }

  public get memory(): Mem {
    const mem = this._memory
    if (!mem) {
      throw Error('core object has no memory')
    }
    return mem
  }
  public set memory(val: Mem) {
    this._memory = val
  }

  protected get sys(): typeof Sys {
    return Sys
  }

  protected get logger(): Logger {
    return this.constructor.logger
  }

  public abstract initMem(): Mem

  public *iterChildren(): Generator<Core> {}

  public create(): void {
    logger.trace(`create for ${this}`)
    // for (const child of this.iterChildren()) {
    //   child.create()
    // }
  }

  public delete(): void {
    logger.trace(`delete for ${this}`)
    // for (const child of this.iterChildren()) {
    //   child.delete()
    // }
  }

  // called on a code update
  // run super after any subclass code
  public reload(): void {
    logger.trace(`reload for ${this}`)
    for (const child of this.iterChildren()) {
      child.reload()
    }
  }

  // called twice per tick, before linking the game and after the last tick
  // run super after any subclass code
  public clean(): void {
    logger.trace(`clean for ${this}`)
    for (const child of this.iterChildren()) {
      child.backoff.with(function () {
        child.clean()
      })
    }
    delete this._memory
  }

  // called once per tick
  // run super after any subclass code
  public linkGame(): void {
    logger.trace(`linkGame for ${this}`)
    for (const child of this.iterChildren()) {
      child.backoff.with(function () {
        child.linkGame()
      })
    }
  }

  // called infrequently before a tick
  // run super after any subclass code
  public refresh(): void {
    logger.trace(`refresh for ${this}`)
    for (const child of this.iterChildren()) {
      child.refresh()
    }
  }

  // called once per tick
  // run super after any subclass code
  public tick(): void {
    logger.trace(`tick for ${this}`)
    for (const child of this.iterChildren()) {
      child.tick()
    }
  }
}

export interface Backing<T extends CoreBacked<any, any>> {
  core?: T
}

export abstract class CoreBacked<
  T extends Backing<any>,
  Mem extends MemInt = CoreMemory
> extends Core<Mem> {

  public static linkProto() {}

  // static from<Mem extends CoreMemory, T extends Backing<any>>(
  //   backing: T
  // ): CoreBacked<T, Mem> {
  //   throw Error('undefined')
  // }

  constructor(protected _backing?: T) {
    super()
  }

  public abstract fetchBacking(): T | undefined

  public get exists(): boolean {
    return typeof this.fetchBacking() !== 'undefined'
  }

  public get backing(): T {
    if (this._backing) {
      return this._backing
    }
    const backing = this.fetchBacking()
    if (backing) {
      this._backing = backing
      return backing
    } else {
      throw Error('no backing found')
    }
  }

  public refresh(): void {
    super.refresh()
    if (!this.exists) {
      this.delete()
    }
  }

  public clean(): void {
    super.clean()
    delete this._backing
  }

  public linkGame(): void {
    super.linkGame()
  }
}
