'use strict'


roles = require 'roles'
tasks = require 'tasks'
logger = require 'logger'
Job = require 'jobs'
u = require 'utils'


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
    logger.info "creep backoff for #{@name}", indent: 1
    throw err


Creep::initFirstTime = ->
  logger.info "first time init for creep #{@name}", indent: 1
  @memory = {} if not @memory?
  @memory.job = null if not @memory.job?
  @memory.role = null if not @memory.role?
  @memory.backoff = 0 if not @memory.backoff?


Creep::init = ->
  @withBackoff ->
    if u.onFreq u.freq.RELOAD
      @initFirstTime()
    logger.trace "init for creep #{@name}", indent: 1
    if @memory.job
      @memory.job = Job.newFromMem @memory.job
    if @memory.role
      @memory.role = Role.newFromMem @memory.role


Creep::pickEdict = ->
  return


Creep::tick = ->
  @withBackoff ->
    if not @job
      @pickEdict()
    if not @task? and @job?
      @task = @job.nextTask()
    if @task?
      @task.do()
      if @task.isDone()
        @task = null
