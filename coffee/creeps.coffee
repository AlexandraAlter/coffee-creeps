'use strict'

Base = require 'base'
Role = require 'roles'
Task = require 'tasks'
Edict = require 'edicts'
logger = require 'logger'
l = logger.fmt
freq = require 'freq'


class Creep.Job extends Base.WithCls
  @newFromMem: (room, opts) ->
    gName = opts.edict.source
    id = opts.edict.id
    gov = room.memory.governors[gname]
    edict = gov.edicts[id]
    opts.edict = edict
    job = new Job opts
    logger.trace "reconstituted #{job}"
    return job

  constructor: (opts) ->
    super()
    { @name, @edict, @task, @status } = opts
    if typeof @edict is 'string'
      @edict = Edict.newFromRef @edict

  toJSON: -> {
    @...,
    edict: @edict.toRef(),
  }


Creep.cleanMemory = ->
  logger.info 'cleaning creeps'
  for cName of Memory.creeps
    if not Game.creeps[cName]?
      delete Memory.creeps[cName]


Creep::backoff = (dur, reason = null) ->
  if @memory.backoff is 0
    @memory.backoff = dur
    reasonStr = if reason? and reason then " because: #{reason}" else ""
    logger.warn l"#{@} backing off for #{dur}#{reasonStr}"


Creep::withBackoff = (func) ->
  if @backedOff
    return
  if @memory.backoff? and @memory.backoff > 0
    @memory.backoff--
    @backedOff = true
    return
  try
    return func.call @
  catch err
    @backoff 10
    throw err


Creep::initFirstTime = ->
  logger.info "initFirstTime for #{@}"
  @memory = {} if not @memory?
  @memory.job = undefined
  @memory.task ?= null
  @memory.role ?= null
  @memory.backoff ?= 0


Creep::init = ->
  @withBackoff ->
    freq.onReload =>
      @initFirstTime()
    logger.trace "init for #{@}", indent: 1
    if @memory.job
      @memory.job = Creep.Job.newFromMem @memory.job
    if @memory.role
      @memory.role = Role.newFromMem @, @memory.role


Creep::findEdict = ->
  for gName, gov of @room.memory.governors
    for eName, edict of gov.edicts
      if (edict instanceof Edict.RunTask) and edict.isReady()
        return edict


Creep::fail = ->
  @edict.fail @
  @memory.task = null
  @memory.state = null
  @memory.edictRef = null
  @backoff 20


Creep::complete = ->
  @edict.complete @
  @memory.task = null
  @memory.state = null
  @memory.edictRef = null


Creep::tick = ->
  @withBackoff ->
    logger.trace l"tick for #{@}"

    # TODO optimise for performance
    if @memory.edictRef
      @edict = Edict.newFromRef @memory.edictRef
    if @memory.task
      @memory.task = Task.newFromMem @memory.task
    if @memory.state
      @memory.state = Task.TaskState.newFromMem @, @memory.state

    if not @edict
      edict = @findEdict()
      if edict
        @memory.edictRef = edict.toRef()
        @edict = edict
        if edict instanceof Edict.RunTask
          @memory.task = edict.makeTask()
          @memory.state = @memory.task.newState @
        @edict.start @
        logger.info l"#{@} starting #{@memory.edictRef}"
      else
        @backoff 20, 'cannot find a job'

    if @memory.task
      try
        res = @memory.task.do @memory.state
        @backoff 3
        logger.debug l"#{@} got #{res}"
        if not res.isValidToplevel()
          throw Error 'invalid toplevel task'
        else if res.adv is 0
        else
          @complete()
      catch err
        @fail()
        throw err


Creep::toString = ->
  "[Creep n=#{@name}]"
