import type { Logger } from './log'
import { getLogger } from './log'
import { Limiter, LimitMem } from './limiter'
import { AnyBacking, BackingProxy } from './backing'
import { MemProxy } from './memory'
import _ from 'lodash4'

const logger = getLogger('core')

export class CoreMem implements LimitMem {
  public failedOn: number | null
  public paused: boolean

  constructor() {
    this.failedOn = null
    this.paused = false
  }
}

export interface CoreInt {
  toString(): string

  iterChildren(): Generator<CoreInt>

  create(): void
  delete(): void
  reload(): void
  clean(): void
  linkGame(): void
  refresh(): void
  tick(): void
}

export interface CoreConstructor extends Function {
  name: string
  logger: Logger
}

export interface Core<Mem extends CoreMem, Back> {
  constructor: CoreConstructor
}

export abstract class Core<
  Mem extends CoreMem,
  Back extends AnyBacking | never
> implements CoreInt {
  public static toString(): string {
    return `[class ${this.name}]`
  }

  protected static logger = logger

  constructor(
    protected readonly limiter: Limiter,
    protected readonly memoryProxy: MemProxy<Mem>,
    protected readonly backingProxy?: BackingProxy<Back>
  ) {}

  public toString(): string {
    return `[${this.constructor.name}]`
  }

  public get memory() {
    return this.memoryProxy.get()
  }
  public set memory(val) {
    this.memoryProxy.set(val)
  }

  public get backing(): Back | undefined {
    return this.backingProxy?.get()
  }

  public *iterChildren(): Generator<CoreInt> {}

  public create(): void {
    logger.trace(`create for ${this}`)
  }

  public delete(): void {
    logger.trace(`delete for ${this}`)
  }

  // called on a code update
  // run super after any subclass code
  public reload(): void {
    logger.trace(`reload for ${this}`)
    this.limiter.with(this, () => {
      this.innerReload()
      for (const child of this.iterChildren()) {
        child.reload()
      }
    })
  }

  public abstract innerReload(): void

  // called twice per tick, before linking the game and after the last tick
  // run super after any subclass code
  public clean(): void {
    logger.trace(`clean for ${this}`)
    this.limiter.with(this, () => {
      for (const child of this.iterChildren()) {
        child.clean()
      }
      this.memoryProxy.clean()
      this.backingProxy?.clean()
      this.innerClean()
    })
  }

  public abstract innerClean(): void

  // called once per tick
  // run super after any subclass code
  public linkGame(): void {
    logger.trace(`linkGame for ${this}`)
    this.limiter.with(this, () => {
      const backing = this.backingProxy?.get()
      if (backing) {
        backing.core = this
      }
      for (const child of this.iterChildren()) {
        child.linkGame()
      }
    })
  }

  // called infrequently before a tick
  // run super after any subclass code
  public refresh(): void {
    logger.trace(`refresh for ${this}`)
    this.limiter.with(this, () => {
      this.innerRefresh()
      for (const child of this.iterChildren()) {
        child.refresh()
      }
    })
  }

  public abstract innerRefresh(): void

  // called once per tick
  // run super after any subclass code
  public tick(): void {
    logger.trace(`tick for ${this}`)
    this.limiter.with(this, () => {
      this.innerTick()
      for (const child of this.iterChildren()) {
        child.tick()
      }
    })
  }

  public abstract innerTick(): void
}
