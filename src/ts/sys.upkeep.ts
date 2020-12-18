import { getLogger } from './log'
import { Role, RoleOpts } from './role'
import { Cortex } from './cortex'

let logger = getLogger('sys.upkeep')

interface UpkeepRoleOpts extends RoleOpts {}

export class UpkeepRole extends Role {
  public getBaseName(opts: UpkeepRoleOpts) {
    void opts
    return 'upkeep'
  }

  public getInitialParts(opts: UpkeepRoleOpts) {
    void opts
    return [MOVE, WORK, CARRY]
  }

  public getExtraParts(opts: UpkeepRoleOpts) {
    void opts
    return [CARRY, CARRY, WORK, MOVE]
  }
}

export class UpkeepCortex extends Cortex {
  protected static logger = logger
}
