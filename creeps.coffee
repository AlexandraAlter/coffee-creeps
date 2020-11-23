'use strict'


roles = require 'roles'
tasks = require 'tasks'
logger = require 'logger'
Job = require 'jobs'
u = require 'utils'


Creep::initFirstTime = ->
  logger.info "first time creep init for #{@name}", indent: 1
  @memory = {} if not @memory?
  @memory.job = null if not @memory.job?
  @memory.role = null if not @memory.role?


Creep::init = ->
  if u.onFreq u.freq.RELOAD
    @initFirstTime()
  logger.trace "creep tick for #{@name}", indent: 1
  if @memory.job
    @memory.job = Job.newFromMem @memory.job
  if @memory.role
    @memory.role = Role.newFromMem @memory.role


# run = ->
#   for name, creep of Game.creeps
#     if not creep.mem?
#       creep.mem = {}
#     role = roles.get creep
#     role.tick()

