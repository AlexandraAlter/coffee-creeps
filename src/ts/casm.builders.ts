import { Cond, Opcode, Reg, Imm, Op } from './casm'
import * as OpC from './casm.opcodes'

export function Add(
  out: Reg,
  in1: Reg,
  in2?: Reg,
  inImm?: Imm,
  cond?: Cond
): Op {
  return [cond, OpC.Add, out, in1, in2, , inImm]
}

export const Sub = (): Op => [, OpC.Sub, , , , , ,]

export const Mul = (): Op => [, OpC.Mul, , , , , ,]

export const B = (): Op => [, OpC.B, , , , , ,]

export const Bl = (): Op => [, OpC.Bl, , , , , ,]
