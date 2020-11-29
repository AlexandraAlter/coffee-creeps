'use strict'

Base = require 'base'
Role = require 'roles'
logger = require 'logger'
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
    edict: @edict.toRef(),
    @...,
  }


Creep.cleanMemory = ->
  logger.info 'cleaning creeps'
  for cName of Memory.creeps
    if not Game.creeps[cName]?
      delete Memory.creeps[cName]


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
    @memory.backoff = 10
    logger.info "backoff for #{@}"
    throw err


Creep::initFirstTime = ->
  logger.info "initFirstTime for #{@}"
  @memory = {} if not @memory?
  @memory.job = null if not @memory.job?
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


Creep::pickEdict = ->
  return


Creep::tick = ->
  @withBackoff ->
    logger.trace "tick for #{@}"

    if not @job
      @pickEdict()
    if not @task? and @job?
      @task = @job.nextTask()
    if @task?
      @task.do()
      if @task.isDone()
        @task = null


Creep::toString = ->
  "[Creep n=#{@name}]"
