import { Cond, Opcode, Reg, Imm, Op } from './casm'
import * as OpC from './casm.opcodes'

export function Add(
  out: Reg,
  in1: Reg,
  in2?: Reg,
  inImm?: Imm,
  cond?: Cond
): Op<any> {
  return [cond, OpC.Add, out, in1, in2, , inImm]
}

export const Sub = (): Op<any> => [, OpC.Sub, , , , , ,]

export const Mul = (): Op<any> => [, OpC.Mul, , , , , ,]

export const B = (): Op<any> => [, OpC.B, , , , , ,]

export const Bl = (): Op<any> => [, OpC.Bl, , , , , ,]
