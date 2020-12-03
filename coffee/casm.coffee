'use strict'

Base = require 'base'
logger = require 'logger'
l = logger.fmt
_ = require 'lodash'

EXEC_LIMIT = 10


class CAsm extends Base
  @verifyOps: ->

  @countOps: (ops) ->
    _.sum(1 for o in ops when o instanceof Op)

  @extractLabels: (ops, maps) ->
    labels = []
    counter = 0
    for o in ops
      if o instanceof Op
        counter += 1
      else if o instanceof Label
        labels.push [o.name, counter]
    for [start, end, casm] in maps
      for [label, offset] in casm.labels
        labels.push [casm.name + '.' + label, start + offset]
    return labels

  @extractMaps: (ops) ->
    freeIndex = 1 + @countOps ops
    includes = (o.casm for o in ops when o instanceof Include)
    ([freeIndex, freeIndex += i.ops.length, i] for i in includes)

  @rebaseOps: (ops, labels, maps) ->
    (o for o in ops when o instanceof Op)

  constructor: (@name, ops) ->
    super()
    CAsm.verifyOps ops
    @maps = CAsm.extractMaps ops
    @labels = CAsm.extractLabels ops, @maps
    @ops = CAsm.rebaseOps ops, @labels, @maps

  getOp: (pc) ->
    if 0 <= pc < @ops.length then return @ops[pc]
    else
      for [start, end, casm] in @maps
        if start <= pc < end
          return casm.ops[pc - start]
    throw Error "could not find pc #{pc}"

  call: (creep) ->
    tally = 0

    loop
      if tally > EXEC_LIMIT
        logger.warn "#{creep} exceeded execution limit"
        return
      tally++

      ex = creep.memory.execState
      op = @getOp ex.pc
      ex.pc += 1
      op.optCall ex, creep

      if ex.yield
        return ex.halt


class ExecState extends Base
  @newFromMem: (creep, vals) ->
    state = new TaskState creep, vals
    logger.trace l"reconstituted #{state}"
    return state

  constructor: (vals) ->
    super()
    Object.assign @, vals
    @pc ?= 0
    @lr ?= 0
    @test ?= false
    Object.defineProperty @, 'yield', value: false, writable: true
    Object.defineProperty @, 'halt', value: false, writable: true

  enqueue: (val) ->
    @sp ?= []
    @sp.push val
    return

  dequeue: ->
    if not @sp? then throw Error 'stack underflow'
    val = @sp.pop()
    delete @sp if _.isEmpty @sp
    return val

  toString: ->
    super().slice(0, -1) + " pc=#{@pc}"


class Label extends Base
  constructor: (@name) -> super()


class Include extends Base
  constructor: (@casm) -> super()


class Cond extends Base
  # @Eq: new Cond 'equal',         (ex) -> ex.eq
  # @Ne: new Cond 'not-equal',     (ex) -> not ex.eq
  @Mi: new Cond 'negative',      (ex) -> not ex.test
  @Pl: new Cond 'positive/zero', (ex) -> ex.test

  @True: @Pl
  @False: @Mi

  # @Ge: new Cond 'greater/equal', (ex) -> ex.eq or ex.gt
  # @Lt: new Cond 'less-than',     (ex) -> ex.lt
  # @Gt: new Cond 'greater/than',  (ex) -> ex.gt
  # @Le: new Cond 'less/equal',    (ex) -> ex.eq or ex.lt

  @Al: new Cond 'always',        (ex) -> true

  constructor: (@name, @func) -> super()

  toString: ->
    super().slice(0, -1) + " #{@name}]"


class Op extends Base
  constructor: (opts) ->
    super()
    {@cond = null} = opts ? {}

  call: (ex, creep) ->

  optCall: (ex, creep) ->
    logger.trace l""
    if not @cond? or @cond.func ex
      @call ex, creep


class Op.Nop extends Op


# arbitrary code
class Op.Func extends Op
  constructor: (@func, opts) -> super(opts)
  call: (ex, creep) ->
    @func.call @, ex, creep


# stack manipulation
class Op.Pop extends Op
  constructor: (@reg, opts) -> super(opts)
  call: (ex, creep) ->
    ex[@reg] = ex.dequeue()


class Op.Push extends Op
  constructor: (@reg, opts) -> super(opts)
  call: (ex, creep) ->
    ex.enqueue(ex[@reg])


# branching
class Op.Branch extends Op
  constructor: (@offset, opts) -> super(opts)
  call: (ex, creep) ->
    ex.pc += @offset


class Op.BranchL extends Op
  constructor: (@offset, opts) -> super(opts)
  call: (ex, creep) ->
    ex.lr = ex.pc + 1
    ex.pc += @offset


class Op.BranchX extends Op
  constructor: (@target, opts) -> super(opts)
  call: (ex, creep) ->
    ex.setPc ex[@target]


class Op.BranchLX extends Op
  constructor: (@target, opts) -> super(opts)
  call: (ex, creep) ->
    ex.lr = ex.pc + 1
    ex.setPc ex[@target]


class Op.BranchLabel extends Op
  constructor: (@label, opts) -> super(opts)
  call: (ex, creep) ->
    throw Error 'Op.BranchLabel remained in the code'


class Op.Halt extends Op
  constructor: (@label, opts) -> super(opts)
  call: (ex, creep) ->
    ex.yield = true
    ex.halt = true


# data manipulation
class Op.GetObject extends Op
  constructor: (@idReg, @outReg) -> super()
  call: (ex, creep) ->
    if ex[@outReg]?
      return
    Object.defineProperty ex, @outReg,
      value: Game.getObjectById ex[@idReg]


class Op.Move extends Op
  constructor: (@targetReg) -> super()
  call: (ex, creep) ->
    res = creep.moveTo ex[@targetReg]
    if res isnt OK
      logger.warn l"#{creep} failed to move with #{res}"
    ex.res = res
    ex.yield = true

# predicates

class Op.IsNextTo extends Op
  constructor: (@targetReg) -> super()
  call: (ex, creep) ->
    super ex, creep
    @test = state.creep.pos.getRangeTo(state.target) <= 1


CAsm.ExecState = ExecState
CAsm.Op = Op
CAsm.Cond = Cond
CAsm.Label = Label

module.exports = CAsm
