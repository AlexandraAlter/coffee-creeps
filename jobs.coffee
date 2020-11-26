'use strict'

Base = require 'base'

u = require 'utils'
logger = require 'logger'

_ = require 'lodash'

# class JobTemplate
#   constructor: (options) ->
#     {
#       @name,
#       @tasks = null,
#       @source = null,
#       @priority = u.priority.MED,
#     } = options

#   @getOrNew: (options) ->
#     if options.name? and not options.tasks?
#       templates[options.name]
#     else
#       new JobTemplate options

#   toJSON = ->
#     name: @name


class Job extends Base
  @newFromMem: (room, opts) ->
    try
      gName = opts.edict.source
      id = opts.edict.id
      gov = room.memory.governors[gname]
      edict = gov.edicts[id]
      opts.edict = edict
      job = new Job opts
      logger.trace 'reconstituted Job', job, indent: 1
      return job
    catch err
      logger.error 'Job.newFromMem failed', err.stack, indent: 1
      return


  constructor: (opts) ->
    super()
    {
      @name,
      @edict,
      @task,
      @status,
    } = opts


  toJSON: -> {
    edict:
      source: @edict.source.name
      id: @edict.id,
    @...,
  }


module.exports = Job
