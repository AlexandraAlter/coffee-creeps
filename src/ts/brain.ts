import { getLogger } from './log'
import { Core, newCoreMemory } from './core'
import type { Cortex } from './cortex'
import _ from 'lodash4'

const logger = getLogger('brain')

@Core.withMemory('brain')
export class Brain extends Core<BrainMemory> {
  static logger = logger;

  private cortexes: Cortex[] = [];

  *iterChildren(): Generator<Cortex> {
    for (let cortex of this.cortexes) {
      yield cortex
    }
  }

  initMem() {
    return newCoreMemory()
  }

  reload() {
    this.cortexes = []
    for (const cortexType of this.sys.cortexTypes) {
      this.cortexes.push(new cortexType)
    }
  }
}
