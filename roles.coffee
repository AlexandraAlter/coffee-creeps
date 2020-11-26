'use strict'

Base = require 'base'

logger = require 'logger'


class Role extends Base
  @variants = {}

  @makeNewVariant: ->
    Gov.variants[@name] = @
    Gov[@name] = @


  @parts: null


  @newFromMem: (creep, opts) ->
    try
      cls = @variants[opts.cls]
      role = new cls room, opts
      logger.trace "reconstituted #{role}"
      return role
    catch err
      logger.error "Gov.newFromMem failed\n#{err.stack}"
      return


  constructor: (@creep, opts) ->
    super()


module.exports = Role
