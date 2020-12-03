'use strict'


class Base
  @toString: ->
    "[class #{@name}]"

  constructor: ->

  toString: ->
    "[#{@constructor.name}]"


class Base.WithCls extends Base
  @toString: ->
    "[class #{@name}]"

  constructor: ->
    super()
    @cls = @constructor.name

  toString: ->
    "[#{@cls}]"


module.exports = Base
