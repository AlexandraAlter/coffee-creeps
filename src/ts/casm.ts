import { getLogger } from './log'
import type { Constructor } from './utils'
import { Worker } from './worker'
import { Task } from './tasks'
import _ from 'lodash'

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

export type Opcode = ((arg1: any, arg2: any, arg3: any, imm: any) => any) &
  ArgUsages

export type Reg = number

export type Imm = any

export type Op = [
  cond: Cond | null | undefined,
  op: Opcode,
  rd: Reg | null | undefined,
  rn: Reg | null | undefined,
  rm: Reg | null | undefined,
  rs: Reg | null | undefined,
  imm: Imm | null | undefined
]

export function check(op: Op): boolean {
  void op
  return true
}

export interface Label {
  label: string
}

export interface Include {
  include: string
}

export interface State {
  regs: number[]
  pc: number
  stack: any[]
}

export class CAsm<T extends Worker> extends Task<T> {
  protected static logger = logger

  public static toString(): string {
    return `[class ${this.name}]`
  }

  public static from(args: (Op | Label | Include)[]): CAsm<any> {
    void args
    throw Error('unimplemented')
  }

  constructor(
    readonly name: string,
    readonly worker: Constructor<T>,
    readonly ops: Op[],
    readonly labels: Label[]
  ) {
    super(name, worker)
  }

  public toString(): string {
    return `[${this.constructor.name}]`
  }

  public toRef(): string {
    return this.constructor.name
  }

  public newState(): State {
    return {
      regs: [],
      pc: 0,
      stack: [],
    }
  }
}
