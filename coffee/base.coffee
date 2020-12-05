'use strict'


class Pretty
  @toString: ->
    "[class #{@name}]"

  constructor: ->

  toString: ->
    "[#{@constructor.name}]"


class Reconst extends Pretty
  @addVariant: ->
    @variants[@name] = @
    @::constructor[@name] = @

  @getVariant: (name) ->
    cls = @variants[name]
    cls ?= super.variants[name]
    return cls

  constructor: ->
    super()
    @cls = @constructor.name

  toString: ->
    "[#{@cls}]"


module.exports = {
  Pretty
  Reconst
}
