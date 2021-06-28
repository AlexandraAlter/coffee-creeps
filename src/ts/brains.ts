import { getLogger } from './log'
import { Core, CoreMem, CoreInt } from './cores'
import { Limiter } from './limiter'
import { MemProxy } from './memory'
import type { Cortex, CortexCons } from './cortexes'
import _ from 'lodash4'

const logger = getLogger('brain')

export class BrainMem extends CoreMem {}

export class Brain extends Core<BrainMem, never> {
  static logger = logger

  private cortexes: Cortex[]
  protected readonly cortexTypes: CortexCons[]

  constructor(
    cortexTypes: CortexCons[]
  ) {
    const logger = getLogger('brain')
    super(
      logger,
      new Limiter('brain'),
      new MemProxy<BrainMem>('brain', () => new BrainMem())
    )
    this.cortexTypes = cortexTypes
    this.cortexes = []
  }

  *iterChildren(): Generator<CoreInt> {
    for (let cortex of this.cortexes) {
      yield cortex
    }
  }

  innerReload() {
    this.cortexes = []
    for (const cortexType of this.cortexTypes) {
      this.cortexes.push(new cortexType())
    }
  }

  innerClean() {}
  innerRefresh() {}
  innerTick() {}
}

export function isBrain(o: any): o is Brain {
  return o instanceof Brain
}
