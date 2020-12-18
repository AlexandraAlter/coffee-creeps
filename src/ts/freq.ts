import { getLogger } from './log'
import { assertNever } from './utils'

let logger = getLogger('freq')

let isSafe = true
let isDebugging = true
let isTesting = true
let isReloading = true

export class Freq {
  static Every = new Freq(1)
  static EOther = new Freq(2)
  static VOften = new Freq(4)
  static Often = new Freq(8)
  static Sometimes = new Freq(16)
  static Regularly = new Freq(32)
  static Occasionally = new Freq(64)
  static VOccasionally = new Freq(128)
  static Rarely = new Freq(256)
  static VRarely = new Freq(512)
  static Reload = new Freq('reload')
  static Safety = new Freq('safety')
  static Debug = new Freq('debug')
  static Test = new Freq('test')

  static onEither<T>(
    freq1: Freq,
    freq2: Freq,
    offset: number | null,
    func: () => T,
  ): T | undefined {
    if (freq1.is(offset) || freq2.is(offset)) {
      return func()
    }
  }

  static finishedReload() {
    logger.info('finished reloading')
    isReloading = false
  }

  constructor(
    readonly freq: number | 'reload' | 'safety' | 'debug' | 'test',
  ) {}

  is(offset: number | null): boolean {
    if (typeof this.freq === 'number') {
      if (isSafe && (offset || 0) >= this.freq) {
        logger.warn('offset longer than freq')
      }
      return Game.time % this.freq === (offset || 0)
    } else if (this.freq === 'reload') {
      return isReloading
    } else if (this.freq === 'safety') {
      return isSafe
    } else if (this.freq === 'debug') {
      return isDebugging
    } else if (this.freq === 'test') {
      return isTesting
    } else {
      return assertNever(this.freq)
    }
  }

  when<T>(offset: number, func: () => T): T | undefined;
  when<T>(func: () => T): T | undefined;
  when<T>(arg1: any, arg2?: any): T | undefined {
    if (typeof arg1 === 'number') {
      if (this.is(arg1)) {
        return arg2()
      }
    } else if (typeof arg1 === 'function') {
      if (this.is(null)) {
        return arg1()
      }
    } else {
      throw Error('invalid call')
    }
  }
}
