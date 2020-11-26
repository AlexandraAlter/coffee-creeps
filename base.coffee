'use strict'


class Base
  @toString: ->
    "[class #{@name}]"

  constructor: ->
    @cls = @constructor.name

  toString: ->
    "[#{@cls}]"


module.exports = Base
