'use strict'

govs = require 'govs'


class CombatGov extends govs.Gov
  @addVariant()

  constructor: () ->
    super()


module.exports = {
  CombatGov
}
