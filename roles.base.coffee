'use strict'


class Role
  @variants = {}

  @parts: null

  @newFromMem: (@creep, opts) ->
    try
      cls = @variants[opts.cls]
      new cls @source, opts
    catch err
      logger.error 'Role construction from memory failed\n', err.stack

  constructor: (@creep, opts) ->
    @cls = @constructor.name


module.exports = Role
