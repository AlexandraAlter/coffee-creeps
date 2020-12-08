'use strict'

Worker = require 'worker'


class TowerWorker extends Worker
  @backingCls = StructureTower
  @defineMemory -> ['towers', @ref]


class ControllerWorker extends Worker
  @backingCls = StructureController
  @defineMemory -> ['controllers', @ref]


class ObserverWorker extends Worker
  @backingCls = StructureObserver
  @defineMemory -> ['observers', @ref]


class NukerWorker extends Worker
  @backingCls = StructureNuker
  @defineMemory -> ['nukers', @ref]


class LinkWorker extends Worker
  @backingCls = StructureLink
  @defineMemory -> ['links', @ref]


class LabWorker extends Worker
  @backingCls = StructureLab
  @defineMemory -> ['labs', @ref]


class TerminalWorker extends Worker
  @backingCls = StructureTerminal
  @defineMemory -> ['terminals', @ref]


class FactoryWorker extends Worker
  @backingCls = StructureFactory
  @defineMemory -> ['factories', @ref]


module.exports = {
  TowerWorker
  ControllerWorker
  ObserverWorker
  NukerWorker
  LinkWorker
  LabWorker
  TerminalWorker
  FactoryWorker
}
