'use strict'

_ = require 'lodash'
log = require 'log'
Edict = require 'edicts'
casm = require 'casm'

logger = log.getLogger 'casm.ops'
l = logger.fmt
Op = casm.Op

ops = {}


class ops.Nop extends Op


# arbitrary code

class ops.Func extends Op
  constructor: (@func, opts) -> super(opts)
  call: (ex, creep) ->
    @func.call @, ex, creep


# stack manipulation

class ops.Pop extends Op
  constructor: (@reg, opts) -> super(opts)
  call: (ex, creep) ->
    ex[@reg] = ex.dequeue()


class ops.Push extends Op
  constructor: (@reg, opts) -> super(opts)
  call: (ex, creep) ->
    ex.enqueue(ex[@reg])


# branching

class ops.Branch extends Op
  constructor: (opts) ->
    super(opts)
    {@reg = null, @offset = null, @label = null, @link = false} = opts
    if not @reg? and not @offset? and not @label?
      throw Error 'must provide a reg, offset, or label'
    @ex = @reg?
  call: (ex, creep) ->
    if @link
      ex.lr = ex.pc + 1
    if @ex
      ex.pc = ex[@reg]
    else
      ex.pc += @offset


class ops.Yield extends Op
  constructor: (opts) -> super(opts)
  call: (ex, creep) ->
    ex.yield = true


class ops.Halt extends Op
  constructor: (opts) -> super(opts)
  call: (ex, creep) ->
    ex.yield = true
    ex.halt = true


# data manipulation


class ops.Set extends Op
  constructor: (@reg, @value) -> super()
  call: (ex, creep) ->
    if @value?
      ex[@reg] = @value
    else
      delete ex[@reg]


class ops.Copy extends Op
  constructor: (@reg1, @reg2) -> super()
  call: (ex, creep) ->
    ex[@reg2] = ex[@reg1]


class ops.GetObject extends Op
  constructor: (@idReg, @outReg) -> super()
  call: (ex, creep) ->
    if ex[@outReg]?
      return
    Object.defineProperty ex, @outReg, value: Game.getObjectById ex[@idReg]


class ops.Move extends Op
  constructor: (@targetReg) -> super()
  call: (ex, creep) ->
    res = creep.moveTo ex[@targetReg]
    if res isnt OK
      logger.warn l"#{creep} failed to move with #{res}"
    ex.res = res
    ex.yield = true


# predicates

class ops.IsNextTo extends Op
  constructor: (@targetReg) -> super()
  call: (ex, creep) ->
    super ex, creep
    @test = state.creep.pos.getRangeTo(state.target) <= 1


module.exports = ops
