import { getLogger } from './log'
import { Core, CoreMem } from './core'
import type { CoreInt } from './core'
import { Limiter } from './limiter'
import { MemProxy } from './memory'
import type { Cortex, CortexConstructor } from './cortex'
import _ from 'lodash4'

const logger = getLogger('brain')

export class BrainMem extends CoreMem {}

export class Brain extends Core<BrainMem, never> {
  static logger = logger

  private cortexes: Cortex[]
  protected readonly cortexTypes: CortexConstructor[]

  constructor(
    cortexTypes: CortexConstructor[]
  ) {
    super(
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
