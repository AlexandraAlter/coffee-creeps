import { getLogger } from './log'
import type { Constructor } from './utils'
import { AnyWorker } from './worker'
import { Task } from './tasks'
import _ from 'lodash4'

const logger = getLogger('casm')

export type Cond = null

export type ArgUsage = 'ign' | 'used' | 'opt' | 'oneOnly' | 'oneOptOnly'
export type ArgUsages = {
  rd: ArgUsage
  rn: ArgUsage
  rm: ArgUsage
  rs: ArgUsage
  imm: ArgUsage
}

export type Opcode<W extends AnyWorker> = ((
  worker: W,
  arg1: any,
  arg2: any,
  arg3: any,
  imm: any
) => any) &
  ArgUsages

export type Reg = number

export type Imm = any

export type Op<W extends AnyWorker> = [
  cond: Cond | null | undefined,
  op: Opcode<W>,
  rd: Reg | null | undefined,
  rn: Reg | null | undefined,
  rm: Reg | null | undefined,
  rs: Reg | null | undefined,
  imm: Imm | null | undefined
]

export function check(op: Op<any>): boolean {
  void op
  return true
}

export interface Label {
  label: string
}

export interface Include<W extends AnyWorker> {
  include: CAsm<W, any>
}

export interface State {
  regs: number[]
  pc: number
  stack: any[]
}

export function newCAsmState(): State {
  return {
    regs: [],
    pc: 0,
    stack: [],
  }
}

type MetaOp<W extends AnyWorker> = Op<W> | Label | Include<W>
type IncludeMap<W extends AnyWorker> = [
  casm: CAsm<W, any>,
  start: number,
  end: number
]
type LabelMap = [Label, number]

export class CAsm<W extends AnyWorker, A> extends Task<W, State, A> {
  protected static logger = logger

  public static toString(): string {
    return `[class ${this.name}]`
  }

  private extractIncludes(ops: MetaOp<W>[]): Include<W>[] {
    const includes = _.filter(ops, 'include') as Include<W>[]
    const allIncludes = _.flatten(includes.map((m) => m.include.includes))
    const uniqIncludes = _.uniq(allIncludes)
    return uniqIncludes
  }

  private extractLabels(ops: MetaOp<W>[]): LabelMap[] {
    const labels: LabelMap[] = []
    ops.reduce((acc, cur) => {
      if (cur instanceof Array) {
        return acc + 1
      } else if ('label' in cur) {
        labels.push([cur, acc])
      }
      return acc
    }, 0)
    return labels
  }

  private extractIncludeMaps(ops: MetaOp<W>[]): IncludeMap<W>[] {
    const incMap: IncludeMap<W>[] = []
    const opCount = _.filter(ops, _.isArray).length
    this.includes.reduce((acc, cur) => {
      const len = cur.include.ops.length
      incMap.push([cur.include, acc, acc + len])
      return acc + len + 1
    }, opCount)
    return incMap
  }

  private rebaseOps(ops: MetaOp<W>[]): Op<W>[] {
    const rebased = _.filter(ops, _.isArray) as Op<W>[]
    return rebased
  }

  readonly includes: Include<W>[]
  readonly labels: LabelMap[]
  readonly includeMaps: IncludeMap<W>[]
  readonly ops: Op<W>[]

  constructor(
    readonly name: string,
    readonly worker: Constructor<W>,
    newState: (args: A) => State,
    args: MetaOp<W>[]
  ) {
    super(name, worker, newState)
    this.includes = this.extractIncludes(args)
    this.labels = this.extractLabels(args)
    this.includeMaps = this.extractIncludeMaps(args)
    this.ops = this.rebaseOps(args)
  }

  public toString(): string {
    return `[${this.constructor.name}]`
  }

  public toRef(): string {
    return this.constructor.name
  }
}
