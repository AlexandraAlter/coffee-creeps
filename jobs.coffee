'use strict'

_ = require 'lodash'
u = require 'utils'
logger = require 'logger'

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


class Job
  @newFromMem: (room, opts) ->
    try
      gName = opts.edict.source
      id = opts.edict.id
      gov = room.memory.governors[gname]
      edict = gov.edicts[id]
      opts.edict = edict
      job = new Job opts
      logger.trace 'reconstituted Job', job, indent: 2
      return job
    catch err
      logger.error 'Job construction from memory failed', err.stack, indent: 2
      return

  constructor: (opts) ->
    {
      @name,
      @edict,
      @task,
      @status,
    } = opts

  toString: ->
    "Job()"

  toJSON: -> {
    edict:
      source: @edict.source.name
      id: @edict.id,
    @...,
  }


module.exports = Job
