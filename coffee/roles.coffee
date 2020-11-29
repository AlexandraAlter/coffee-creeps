'use strict'

Base = require 'base'
logger = require 'logger'
l = logger.fmt
_ = require 'lodash'


class Role extends Base
  @variants = {}

  @makeNewVariant: ->
    Role.variants[@name] = @
    Role[@name] = @

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
