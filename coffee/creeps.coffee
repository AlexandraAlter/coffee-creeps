'use strict'

Base = require 'base'
Role = require 'roles'
Task = require 'tasks'
Edict = require 'edicts'
logger = require 'logger'
l = logger.fmt
freq = require 'freq'


class Creep.Job extends Base
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
  @memory.backoff = dur
  reasonStr = if reason? and reason then " because: #{reason}" else ""
  logger.info l"#{@} backing off for #{dur}#{reasonStr}"


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
  @memory.task = null if not @memory.task?
  @memory.role = null if not @memory.role?
  @memory.backoff = 0 if not @memory.backoff?


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
  @memory.edictRef = null
  @backoff 20


Creep::complete = ->
  @edict.complete @
  @memory.task = null
  @memory.edictRef = null


Creep::tick = ->
  @withBackoff ->
    logger.trace l"tick for #{@}"

    # TODO optimise for performance
    if @memory.edictRef
      @edict = Edict.newFromRef @memory.edictRef
    if @memory.task
      @memory.task = Task.newFromMem @, @memory.task

    if not @edict
      edict = @findEdict()
      if edict
        @memory.edictRef = edict.toRef()
        @edict = edict
        if edict instanceof Edict.RunTask
          @memory.task = edict.makeTask @
        @edict.start @
        logger.info l"#{@} starting #{@memory.edictRef}"
      else
        @backoff 20, 'cannot find a job'

    if @memory.task
      try
        @edict.task.do @memory.task
      catch err
        @fail()
        logger.error l"#{@} failed task"
        throw err
      if @edict.task.isDone @memory.task
        @complete()


Creep::toString = ->
  "[Creep n=#{@name}]"
