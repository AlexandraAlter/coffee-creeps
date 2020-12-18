import { getLogger } from './log'
import { CoreBacked, newCoreMemory } from './core'
import _ from 'lodash4'

const logger = getLogger('zone');

declare global {
  interface Room {
    core?: Zone
  }
}

export interface Opts {
}

@CoreBacked.withMemory<Zone>(function() { return this.memPath })
export class Zone extends CoreBacked<Room, RoomMemory>{

  protected static logger = logger;

  readonly memPath: Array<string>
  readonly name: string

  constructor(
    ref: Room | string,
    opts: Opts = {},
  ) {
    if (typeof ref === 'object') {
      super(ref)
      ref = ref.name
    } else {
      super()
    }
    this.name = ref
    this.memPath = ['rooms', ref]
  }

  public toString() {
    return super.toString().slice(0, -1) + ` ${this.name}]`
  }

  public get ref(): string {
    return this.name
  }

  public fetchBacking(): Room {
    return Game.rooms[this.name]
  }

  public initMem() {
    return newCoreMemory()
  }
}
