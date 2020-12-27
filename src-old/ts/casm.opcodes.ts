import { ArgUsages, Opcode } from './casm'
import _ from 'lodash4'

const none: ArgUsages = {
  rd: 'ign',
  rn: 'ign',
  rm: 'ign',
  rs: 'ign',
  imm: 'ign',
}

const oneArg: ArgUsages = {
  ...none,
  rd: 'used',
  rn: 'oneOnly',
  imm: 'oneOnly',
}

const oneArgOpt: ArgUsages = {
  ...none,
  rd: 'used',
  rn: 'oneOptOnly',
  imm: 'oneOptOnly',
}

const twoArg: ArgUsages = {
  ...none,
  rd: 'used',
  rn: 'used',
  rm: 'used',
  imm: 'used',
}

const threeArg: ArgUsages = {
  rd: 'used',
  rn: 'used',
  rm: 'used',
  rs: 'used',
  imm: 'used',
}

export const Add: Opcode<any> = _.merge(function () {}, oneArg)

export const Sub: Opcode<any> = _.merge(function () {}, oneArg)

export const Mul: Opcode<any> = _.merge(function () {}, oneArg)

export const B: Opcode<any> = _.merge(function () {}, oneArg)

export const Bl: Opcode<any> = _.merge(function () {}, oneArg)
