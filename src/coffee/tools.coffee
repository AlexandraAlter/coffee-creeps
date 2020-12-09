'use strict'

log = require 'log'

logger = log.getLogger 'tools'
l = log.fmt


print = (obj, depth = 0) ->
  console.log('|-'.repeat(depth) + obj)


printDeep = (obj, depth = 0) ->
  if obj is null
    print 'null', depth
  else if typeof obj is 'object'
    for k in Object.keys obj
      v = obj[k]
      if (v isnt null) and (typeof v is 'object')
        print k + ':', depth
        printDeep(obj[k], depth + 1)
      else
        print k + ': ' + v, depth
  else
    print obj, depth
  return


module.exports = {
  toString: -> '[module tools]'
  print
  printDeep
}
