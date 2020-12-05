'use strict'

logger = require 'logger'

tools = {}


tools.setLogLevel = logger.setLevel

tools.print = (obj, depth = 0) ->
  console.log('|-'.repeat(depth) + obj)

tools.printDeep = (obj, depth = 0) ->
  if obj is null
    tools.print 'null', depth
  else if typeof obj is 'object'
    for k in Object.keys obj
      v = obj[k]
      if (v isnt null) and (typeof v is 'object')
        tools.print k + ':', depth
        tools.printDeep(obj[k], depth + 1)
      else
        tools.print k + ': ' + v, depth
  else
    tools.print obj, depth
  return


module.exports = tools
