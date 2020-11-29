'use strict'


Gov = require 'governors'


class CombatGov extends Gov
  Gov.variants[@name] = @

  constructor: () ->
    super()



module.exports = CombatGov
