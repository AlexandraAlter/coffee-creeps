'use strict'

Base = require 'base'
CAsm = require 'casm'
logger = require 'logger'
_ = require 'lodash'

Include = CAsm.Include
Label = CAsm.Label
Cond = CAsm.Cond
Op = CAsm.Op
l = logger.fmt

procs = {}


procs.moveTo = new CAsm 'moveTo', [
  new Label 'loop'
  new Op.Move 1
  new Op.IsNextTo 1
  new Op.Branch label: 'loop', cond: Cond.False
  new Op.Set 1, null
  new Op.Branch reg: 'lr'
]


procs.getEnergy = new CAsm 'getEnergy', [
  new CAsm.Include procs.moveTo
  new Op.Copy 'lr', 0
  new Op.Branch label: 'moveTo', link: true
  new Op.Copy 0, 'lr'
  new Op.Set 0, null
  new Op.Set 1, null
  new Op.Branch reg: 'lr'
]


procs.refill = new CAsm 'refill', [
  new CAsm.Include procs.moveTo
  new CAsm.Include procs.getEnergy
  new Op.Copy 'lr', 0
  new Op.Branch label: 'getEnergy', link: true
  new Op.Copy 0, 'lr'
  new Op.Set 0, null
  new Op.Set 1, null
  new Op.Branch reg: 'lr'
]


module.exports = procs
