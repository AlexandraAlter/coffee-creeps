'use strict'

_ = require 'lodash'
log = require 'log'
Core = require 'core'
Rehydrator = require 'rehydrator'

logger = log.getLogger 'role'
l = log.fmt


class Role extends Core
  @rehydrator: new Rehydrator @

  @selectParts: (maxCost) -> []

  @costOfParts: (parts) ->
    return _.sum(BODYPART_COST[part] for part in parts)

  @toJSON: -> @name

  @clsFromMem: (str) ->
    cls = @variants[str]
    throw 'invalid class' if not cls?
    return cls

  @newFromMem: (creep, opts) ->
    if typeof opts is 'string'
      cls = @variants[opts]
      role = new cls creep, {}
    else
      cls = @variants[opts.cls]
      role = new cls creep, opts
    logger.trace l"reconstituted #{role}"
    return role

  constructor: (@creep, opts) ->
    super()

  toJSON: -> @cls


module.exports = Role

