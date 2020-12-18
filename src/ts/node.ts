import { getLogger } from './log'
import { Core, newCoreMemory } from './core'
import { Rehydrator } from './rehydrator'
import { Zone } from './zone'
import _ from 'lodash4'

const logger = getLogger('node');

if (!Memory.nodeTtl) {
  Memory.nodeTtl = 10
}

export function newNodeMemory(): NodeMemory {
  return {
    ttl: Memory.nodeTtl,
    cls: 'Node',
    ...newCoreMemory(),
  }
}

export interface Opts {}

export class Node extends Core<NodeMemory> {
  static logger = logger;
  static rehydrator: Rehydrator<typeof Node, NodeMemory> = new Rehydrator()

  constructor(
    readonly name: string,
    readonly zone: Zone,
    opts: Opts,
  ) {
    super()
  }

  get ref(): string {
    return this.name
  }

  get ttl(): number {
    return this.memory.ttl
  }

  initMem() {
    return newNodeMemory()
  }

  tick() {
    if (Game.time > this.ttl) {
      this.delete()
    }
  }
}
