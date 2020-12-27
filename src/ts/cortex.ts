import { getLogger } from './log'
import { Core, CoreMem } from './core'
import _ from 'lodash4'

const logger = getLogger('cortex')

export class CortexMem extends CoreMem {
}

export interface CortexConstructor extends Function {
  new (): Cortex
}

export class Cortex extends Core<CortexMem, never> {
  protected static logger = logger

  readonly cortexes: Cortex[] = [];

  innerReload() {}
  innerClean() {}
  innerRefresh() {}
  innerTick() {}

}
