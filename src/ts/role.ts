import { getLogger, fmt as l } from './log'
import _ from 'lodash'

let logger = getLogger('role')
void logger

export enum Strategy {
  Best = 'best',
  Optimal = 'optimal',
  Conserve = 'conserve',
}

export function costOfParts(parts: BodyPartConstant[]): number {
  return _.sum(parts, (part) => BODYPART_COST[part])
}

export function linearGuess(
  parts: BodyPartConstant[],
  countEqns: number[][],
  costEqns: number[][],
): BodyPartConstant[] {
  void parts, countEqns, costEqns
  return []
}

export interface RoleOpts {
  maxCost: number
}

export abstract class Role<Opts = RoleOpts> {
  static toString(): string {
    return `[class ${this.name}]`
  }

  public static roleName: string = 'unknown'

  constructor() {}

  public toString(): string {
    return `[${this.constructor.name}]`
  }

  public abstract getInitialParts(opts: RoleOpts): BodyPartConstant[]

  public getInitialCost(opts: RoleOpts): number {
    return costOfParts(this.getInitialParts(opts))
  }

  public abstract getExtraParts(opts: RoleOpts): BodyPartConstant[]

  public getParts(opts: RoleOpts): BodyPartConstant[] {
    const parts = this.getInitialParts(opts)
    const extra = this.getExtraParts(opts)
    const len = extra.length
    let cost = costOfParts(parts)
    let count = 0
    let next = extra[count % len]
    while (cost + BODYPART_COST[next] < opts.maxCost) {
      parts.push(next)
      cost += BODYPART_COST[next]
      count += 1
      next = extra[count % len]
    }
    return parts
  }

  public abstract getBaseName(opts: RoleOpts): string

  public getName(opts: RoleOpts): string {
    const baseName = this.getBaseName(opts)
    var name
    for (let i = 0; i < 3; i++) {
      name = baseName + '_' + Math.random().toString(36).substr(2, 5)
      if (!Game.creeps[name]) {
        return name
      }
    }
    throw Error('could not generate a name')
  }

  public isPossible(opts: RoleOpts): boolean {
    return opts.maxCost > costOfParts(this.getParts(opts))
  }

  public makeMem(opts: RoleOpts): object {
    void opts
    return {
      role: this.constructor.roleName,
    }
  }
}

export interface Role {
  constructor: {
    name: string
    roleName: string
  }
}
