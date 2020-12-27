import { getLogger } from './log'
import _ from 'lodash4'

const logger = getLogger('backoff')

if (!Memory.globalBackoff || typeof Memory.globalBackoff != 'number') {
  Memory.globalBackoff = 10
}

export interface LimitMem {
  failedOn: number | null
  paused: boolean
}

export interface Limitable {
  memory: LimitMem
}

export class LimitError extends Error {
  constructor(msg: string) {
    super(msg)
    this.name = 'LimitError'
  }
}

export interface Opts {
  error?: boolean
  rethrow?: boolean
  norecur?: boolean
}

export class Limiter {
  static toString(): string {
    return `[class ${this.name}]`
  }

  protected static logger = logger

  private checkedOn: number | null = null
  private paused: boolean = false
  private backoff: number

  constructor(private name: string, backoff?: number) {
    this.backoff = backoff ?? Memory.globalBackoff
  }

  toString(): string {
    return `[${this.constructor.name}]`
  }

  private failedOn(core: Limitable): number | null {
    return core.memory.failedOn
  }
  private setFailedOn(core: Limitable, val: number | null): void {
    core.memory.failedOn = val
  }

  private escapeTime(core: Limitable): number | null {
    const failedOn = this.failedOn(core)
    return failedOn ? failedOn + this.backoff : null
  }

  private remainingTime(core: Limitable): number | null {
    const failedOn = this.failedOn(core)
    return failedOn ? failedOn + this.backoff - Game.time : null
  }

  with<C extends Limitable>(
    core: C,
    func: (this: C) => void,
    opts: Opts = {}
  ) {
    const { error = false, rethrow = error, norecur = true } = opts

    if (this.checkedOn === Game.time) {
      if (error) {
        throw new LimitError('already checked this tick')
      }
      return
    }

    if (this.paused) {
      return
    }

    const escapeTime = this.escapeTime(core)
    if (escapeTime) {
      if (Game.time < escapeTime) {
        logger.info(`${core} backing off for ${this.remainingTime}`)
        if (norecur) {
          this.checkedOn = Game.time
        }
        if (error) {
          throw new LimitError('still in backoff')
        }
        return
      } else {
        logger.info(`${core} escapes backoff`)
        this.setFailedOn(core, null)
      }
    }

    try {
      return func.call(core)
    } catch (e) {
      this.setFailedOn(core, (this.checkedOn = Game.time))
      logger.info(`backoff on ${core} for ${this.backoff}`)
      if (rethrow) {
        throw e
      }
      logger.error(e.stack)
      return
    }
  }

  withRethrow<C extends Limitable>(core: C, func: (this: void) => void) {
    this.with(core, func, { rethrow: true })
  }

  withErr<C extends Limitable>(core: C, func: (this: void) => void) {
    this.with(core, func, { error: true })
  }

  withErrRecur<C extends Limitable>(core: C, func: (this: void) => void) {
    this.with(core, func, { error: true, norecur: false })
  }

  pause<C extends Limitable>(core: C) {
    logger.info(`pausing ${core} limiter ${this.name}`)
    this.paused = true
  }

  unpause<C extends Limitable>(core: C) {
    logger.info(`unpausing ${core} limiter ${this.name}`)
    this.paused = false
  }
}
