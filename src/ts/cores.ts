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
  limiter: Limiter
  memory: LimitMem
  logger: Logger

  children(): Generator<CoreInt>

  create(): void
  delete(): void

  reload(): void
  refresh(): void
  link(): void
  tick(): void
  clean(): void
}

export abstract class Core<
  Mem extends CoreMem,
  Back extends AnyBacking | never
> implements CoreInt {
  public static toString(): string {
    return `[class ${this.name}]`
  }

  constructor(
    public readonly logger: Logger,
    public readonly limiter: Limiter,
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

  public *children(): Generator<CoreInt> {}

  public create(): void {
    logger.trace(`create for ${this}`)
  }

  public delete(): void {
    logger.trace(`delete for ${this}`)
  }

  // called on a code update
  public reload(): void {}

  // called once per tick, after linking the game and after the last tick
  public clean(): void {}

  // called once per tick
  public link(): void {}

  // called infrequently before a tick
  public refresh(): void {}

  // called once per tick
  public tick(): void {}
}

export function isCoreInt(o: any): o is CoreInt {
  return o instanceof Core
}

export function isCore(o: any): o is Core<any, any> {
  return o instanceof Core
}
