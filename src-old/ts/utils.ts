import { getLogger } from './log'

let logger = getLogger('utils')

export type HasConstructor<T> = { constructor: T }

export type Constructor<T> = { new(...args: any[]): T }

export function assertNever(x: never): never {
  let msg = `reached unreachable code with x=${x}`
  logger.fatal(msg)
  throw Error(msg)
}

export function applyMixins(derivedCtor: any, constructors: any[]) {
  constructors.forEach((baseCtor) => {
    Object.getOwnPropertyNames(baseCtor.prototype).forEach((name) => {
      if (name === 'constructor') {
        return
      }
      const desc = Object.getOwnPropertyDescriptor(baseCtor.prototype, name)
      if (desc) {
        Object.defineProperty(derivedCtor.prototype, name, desc)
      }
    })
  })
}

export function throwScreepsError(ret: ScreepsReturnCode) {
  if (ret === ERR_NOT_OWNER) {
    throw Error('not owner')
  } else if (ret === ERR_NO_PATH) {
    throw Error('no path')
  } else if (ret === ERR_NAME_EXISTS) {
    throw Error('name exists')
  } else if (ret === ERR_BUSY) {
    throw Error('busy')
  } else if (ret === ERR_NOT_FOUND) {
    throw Error('not found')
  } else if (ret === ERR_NOT_ENOUGH_ENERGY) {
    throw Error('not enough resources/energy/extensions')
  } else if (ret === ERR_INVALID_TARGET) {
    throw Error('invalid target')
  } else if (ret === ERR_FULL) {
    throw Error('full')
  } else if (ret === ERR_NOT_IN_RANGE) {
    throw Error('not in range')
  } else if (ret === ERR_INVALID_ARGS) {
    throw Error('invalid args')
  } else if (ret === ERR_TIRED) {
    throw Error('tired')
  } else if (ret === ERR_NO_BODYPART) {
    throw Error('no bodypart')
  } else if (ret === ERR_RCL_NOT_ENOUGH) {
    throw Error('rcl not enough')
  } else if (ret === ERR_GCL_NOT_ENOUGH) {
    throw Error('gcl not enough')
  }
}

export const errToName: { [key: number]: string } = {
  [OK as number]: 'okay',
  [ERR_NOT_OWNER as number]: 'not owner',
  [ERR_NO_PATH as number]: 'no path',
  [ERR_BUSY as number]: 'busy',
  [ERR_NAME_EXISTS as number]: 'name exists',
  [ERR_NOT_FOUND as number]: 'not found',
  [ERR_NOT_ENOUGH_RESOURCES as number]: 'not enough resources',
  [ERR_NOT_ENOUGH_ENERGY as number]: 'not enough energy',
  [ERR_INVALID_TARGET as number]: 'invalid target',
  [ERR_FULL as number]: 'full',
  [ERR_NOT_IN_RANGE as number]: 'not in range',
  [ERR_INVALID_ARGS as number]: 'invalid args',
  [ERR_TIRED as number]: 'tired',
  [ERR_NO_BODYPART as number]: 'no bodypart',
  [ERR_NOT_ENOUGH_EXTENSIONS as number]: 'not enough extensions',
  [ERR_RCL_NOT_ENOUGH as number]: 'RCL not enough',
  [ERR_GCL_NOT_ENOUGH as number]: 'GCL not enough',
}
