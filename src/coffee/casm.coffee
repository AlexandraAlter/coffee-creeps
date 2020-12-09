'use strict'

Edict = require 'edicts'
logger = require 'logger'
l = logger.fmt
_ = require 'lodash'

EXEC_LIMIT = 10


class CAsm
  @toString: -> "[class #{@name}]"

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
    CAsm.verifyOps ops
    @includes = CAsm.extractIncludes ops
    @maps = CAsm.extractMaps ops, @includes
    @labels = CAsm.extractLabels ops, @maps
    @ops = CAsm.rebaseOps ops, @labels, @maps

  toString: -> "[#{@constructor.name}]"

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


class ExecState
  @newFromMem: (vals) ->
    state = new ExecState vals
    logger.trace l"reconstituted #{state}"
    return state

  constructor: (vals) ->
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

  toString: -> "[#{@constructor.name} pc=#{@pc}]"


class Label
  @toString: -> "[class #{@name}]"
  constructor: (@name) ->
  toString: -> "[#{@constructor.name}]"


class Include
  @toString: -> "[class #{@name}]"
  constructor: (@casm) ->
  toString: -> "[#{@constructor.name}]"


class Cond
  @toString: -> "[class #{@name}]"

  @Mi: new Cond 'negative',      (ex) -> not ex.test
  @Pl: new Cond 'positive/zero', (ex) -> ex.test
  @True: @Pl
  @False: @Mi
  @Al: new Cond 'always',        (ex) -> true

  constructor: (@name, @func) ->

  toString: -> "[#{@constructor.name} #{@name}]"


class Op
  @toString: -> "[class #{@name}]"

  constructor: (opts) ->
    {@cond = null} = opts ? {}

  call: (ex, creep) ->

  optCall: (ex, creep) ->
    logger.trace l""
    if not @cond? or @cond.func ex
      @call ex, creep

  toString: -> "[#{@constructor.name}]"


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

  toString: -> super()[...-1] + " #{JSON.stringify @params}]"


module.exports = {
  CAsm
  ExecState
  Op
  Cond
  Label
  Include
  Task
}
