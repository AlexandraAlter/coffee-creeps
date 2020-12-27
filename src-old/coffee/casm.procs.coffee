'use strict'

_ = require 'lodash'
casm = require 'casm'
ops = require 'casm.ops'
log = require 'log'

logger = log.getLogger 'casm.procs'
l = logger.fmt
CAsm = casm.CAsm
Include = casm.Include
Label = casm.Label
Cond = casm.Cond
Op = casm.Op

procs = {}


procs.moveTo = new CAsm 'moveTo', [
  new Label 'loop'
  new ops.Move 1
  new ops.IsNextTo 1
  new ops.Branch label: 'loop', cond: Cond.False
  new ops.Set 1, null
  new ops.Branch reg: 'lr'
]


procs.getEnergy = new CAsm 'getEnergy', [
  new CAsm.Include procs.moveTo
  new ops.Copy 'lr', 0
  new ops.Branch label: 'moveTo', link: true
  new ops.Copy 0, 'lr'
  new ops.Set 0, null
  new ops.Set 1, null
  new ops.Branch reg: 'lr'
]


procs.refill = new CAsm 'refill', [
  new CAsm.Include procs.moveTo
  new CAsm.Include procs.getEnergy
  new ops.Copy 'lr', 0
  new ops.Branch label: 'getEnergy', link: true
  new ops.Copy 0, 'lr'
  new ops.Set 0, null
  new ops.Set 1, null
  new ops.Branch reg: 'lr'
]


module.exports = procs
