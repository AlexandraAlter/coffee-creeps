import { getLogger } from './log'
import { Core, newCoreMemory } from './core'
import _ from 'lodash4'

const logger = getLogger('cortex')

@Core.withMemory('brain')
export class Cortex extends Core {
  protected static logger = logger

  readonly cortexes: Cortex[] = [];

  *iterChildren() {}

  initMem() {
    return newCoreMemory()
  }
}
