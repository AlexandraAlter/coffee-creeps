'use strict'

logger = require 'logger'


m = {}

m.setLogLevel = logger.setLevel

m.print = (obj, depth = 0) ->
  console.log('|-'.repeat(depth) + obj)

m.printDeep = (obj, depth = 0) ->
  if obj is null
    m.print 'null', depth
  else if typeof obj is 'object'
    for k in Object.keys obj
      v = obj[k]
      if (v isnt null) and (typeof v is 'object')
        m.print k + ':', depth
        m.printDeep(obj[k], depth + 1)
      else
        m.print k + ': ' + v, depth
  else
    m.print obj, depth
  return


module.exports = m
