'use strict'

Base = require 'base'
Edict = require 'edicts'
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
      labels.push [casm.name, start]
      for [label, offset] in casm.labels
        labels.push [casm.name + '.' + label, start + offset]
    return labels

  @extractIncludes: (ops) ->
    myIncludes = (o.casm for o in ops when o instanceof Include)
    for i in myIncludes
      if not i instanceof CAsm
        throw Error 'including a non-CAsm'
    includes = _.flatten(i.includes for i in myIncludes)
    _.uniq(includes)

  @extractMaps: (ops, includes) ->
    freeIndex = 1 + @countOps ops
    ([freeIndex, freeIndex += i.ops.length, i] for i in includes)

  @rebaseOps: (ops, labels, maps) ->
    (o for o in ops when o instanceof Op)

  constructor: (@name, ops) ->
    super()
    CAsm.verifyOps ops
    @includes = CAsm.extractIncludes ops
    @maps = CAsm.extractMaps ops, @includes
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
  @newFromMem: (vals) ->
    state = new ExecState vals
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
  @Mi: new Cond 'negative',      (ex) -> not ex.test
  @Pl: new Cond 'positive/zero', (ex) -> ex.test
  @True: @Pl
  @False: @Mi
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


class Op.Yield extends Op
  constructor: (opts) -> super(opts)
  call: (ex, creep) ->
    ex.yield = true


class Op.Halt extends Op
  constructor: (opts) -> super(opts)
  call: (ex, creep) ->
    ex.yield = true
    ex.halt = true


# data manipulation


class Op.Set extends Op
  constructor: (@reg, @value) -> super()
  call: (ex, creep) ->
    if @value?
      ex[@reg] = @value
    else
      delete ex[@reg]


class Op.Copy extends Op
  constructor: (@reg1, @reg2) -> super()
  call: (ex, creep) ->
    ex[@reg2] = ex[@reg1]


class Op.GetObject extends Op
  constructor: (@idReg, @outReg) -> super()
  call: (ex, creep) ->
    if ex[@outReg]?
      return
    Object.defineProperty ex, @outReg, value: Game.getObjectById ex[@idReg]


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


class Task extends Edict
  @makeNewVariant()

  @casm: new CAsm '', []

  constructor: (source, opts) ->
    super source, opts
    {@params = {}} = opts

  apply: (creep) ->
    creep.memory.taskRef = @cls
    creep.memory.state = new ExecState @params

  clean: ->
    ref = @toRef()
    count = 0
    for cName, creep of Game.creeps
      if creep.memory.edictRef is ref
        count += 1
    if count isnt @curWorkers
      logger.warn "#{@} has mismatched workers, #{count} not #{@curWorkers}"
      @curWorkers = count

  toString: ->
    super().slice(0, -1) + " #{JSON.stringify @params}]"


module.exports = {
  CAsm
  ExecState
  Op
  Cond
  Label
  Include
  Task
}
