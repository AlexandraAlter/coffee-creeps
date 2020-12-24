import { getLogger } from './log'
import { Core } from './core'
import _ from 'lodash4'

const logger = getLogger('backoff')

let globalBackoff: number = Memory.globalBackoff
if (!globalBackoff || typeof globalBackoff != 'number') {
  globalBackoff = Memory.globalBackoff = 10
}

export interface BackoffMem {
  failedOn: number | null
  paused: boolean
}

export class BackoffError extends Error {
  constructor(msg: string) {
    super(msg)
    this.name = 'BackoffError'
  }
}

export interface Opts {
  error?: boolean
  rethrow?: boolean
  norecur?: boolean
}

export class Backoff<T extends Core> {
  static toString(): string {
    return `[class ${this.name}]`
  }

  private checkedOn: number | null = null
  private paused: boolean = false
  private backoff: number

  constructor(readonly core: T, backoff?: number) {
    this.backoff = backoff ?? globalBackoff
  }

  toString(): string {
    return `[${this.constructor.name}]`
  }

  get failedOn(): number | null {
    return this.core.memory.failedOn
  }
  set failedOn(val: number | null) {
    this.core.memory.failedOn = val
  }

  get escapeTime(): number | null {
    if (this.failedOn) {
      return this.failedOn + this.backoff
    } else {
      return null
    }
  }

  get remainingTime(): number | null {
    if (this.failedOn) {
      return this.failedOn + this.backoff - Game.time
    } else {
      return null
    }
  }

  with(func: (this: T) => void, opts: Opts = {}) {
    const { error = false, rethrow = error, norecur = true } = opts

    if (this.checkedOn === Game.time) {
      if (error) {
        throw new BackoffError('already checked this tick')
      }
      return
    }

    if (this.paused) {
      return
    }

    if (this.escapeTime) {
      if (Game.time < this.escapeTime) {
        logger.info(`${this.core} backing off for ${this.remainingTime}`)
        if (norecur) {
          this.checkedOn = Game.time
        }
        if (error) {
          throw new BackoffError('still in backoff')
        }
        return
      } else {
        logger.info(`${this.core} escapes backoff`)
        this.failedOn = null
      }
    }

    try {
      return func.call(this.core)
    } catch (e) {
      this.checkedOn = this.failedOn = Game.time
      logger.info(`backoff on ${this.core} for ${this.backoff}`)
      if (rethrow) {
        throw e
      }
      logger.error(e.stack)
      return
    }
  }

  withRethrow(func: () => void) {
    this.with(func, { rethrow: true })
  }

  withErr(func: () => void) {
    this.with(func, { error: true })
  }

  withErrRecur(func: () => void) {
    this.with(func, { error: true, norecur: false })
  }

  pause() {
    logger.info(`pausing ${this.core}`)
    this.paused = true
  }

  unpause() {
    logger.info(`unpausing ${this.core}`)
    this.paused = false
  }
}
