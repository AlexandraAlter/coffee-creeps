import { getLogger } from './log'
import { Core, CoreMem } from './cores'
import { Refable } from './libs'
import _ from 'lodash4'

const logger = getLogger('cortex')

export class CortexMem extends CoreMem {}

export interface CortexInt {}

export interface CortexCons extends Function, Refable {
  new (): Cortex
}

export class Cortex extends Core<CortexMem, never> {
  protected static logger = logger

  readonly cortexes: Cortex[] = []

  innerReload() {}
  innerClean() {}
  innerRefresh() {}
  innerTick() {}
}

export function isCortex(o: any): o is Cortex {
  return o instanceof Cortex
}
