import _ from 'lodash4'
import { getLogger } from './log'

const logger = getLogger('memory')

type PropKind = (string | number)[] | string
type PropFuncKind<T> = PropKind | ((this: MemProxy<T>) => PropKind)

export class MemProxy<T> {
  public static toString(): string {
    return `[class ${this.name}]`
  }

  protected static logger = logger

  private cache: T | null = null

  public constructor(
    private propFunc: PropFuncKind<T>,
    private initMem: () => T
  ) {}

  private get prop(): PropKind {
    if (typeof this.propFunc === 'function') {
      return this.propFunc()
    } else {
      return this.propFunc
    }
  }

  public get(): T {
    if (this.cache) {
      return this.cache
    }
    const path = this.prop
    if (typeof path === 'undefined') {
      throw Error('undefined memory path')
    }
    let mem = _.get(Memory, path)
    if (typeof mem === 'undefined') {
      mem = this.initMem()
      _.set(Memory, path, mem)
    }
    return mem as T
  }

  public set(val: T) {
    const path = this.prop
    if (typeof path === 'undefined') {
      throw Error('undefined memory path')
    }
    _.set(Memory, path, (this.cache = val))
  }

  public clean() {
    this.cache = null
  }
}
