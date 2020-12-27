import _ from 'lodash4'
import { getLogger } from './log'
import type { Logger } from './log'
import { Backoff, BackoffMem } from './backoff'

const logger = getLogger('memory')

type PropKind = (string | number)[] | string
type PropFuncKind<T> = PropKind | ((this: T) => PropKind)

export class Memory<T> {
  private cache: T | null = null

  constructor() {
  }

  // public get(): T {
  //   if (this.cache) {
  //     return this.cache
  //   }
  //   const path = getPath.call(this)
  //   if (typeof path === 'undefined') {
  //     throw Error('undefined memory path')
  //   }
  //   let mem = _.get(Memory, path)
  //   if (typeof mem === 'undefined') {
  //     mem = this.initMem()
  //     _.set(Memory, path, mem)
  //   }
  //   return mem as T
  // }

  // public set(val: T) {
  //   const path = getPath.call(this)
  //   if (typeof path === 'undefined') {
  //     throw Error('undefined memory path')
  //   }
  //   _.set(Memory, path, (this.cache = val))
  // }
}
