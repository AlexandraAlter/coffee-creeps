import { getLogger } from './log'
import { Freq } from './freq'
import { SysCls } from './sys'
import { CoreInt } from './cores'
import _ from 'lodash4'

let logger = getLogger('main')
void logger

export function setupGlobals(): void {}

export function loopCores(core: CoreInt, func: (this: CoreInt) => void) {
  core.limiter.with(core, func)

  for (const child of core.children()) {
    loopCores(child, func)
  }
}

export function loop(): void {
  const sys = new SysCls([])

  Freq.Reload.when(() => {
    loopCores(sys, function () {
      this.logger.trace(`reload for ${this}`)
      this.reload()
    })
    Freq.finishedReload()
  })

  loopCores(sys, function () {
    Freq.Rarely.when(() => {
      this.logger.trace(`refresh for ${this}`)
      this.refresh()
    })

    this.logger.trace(`link for ${this}`)
    this.link()
    this.logger.trace(`tick for ${this}`)
    this.tick()
  })

  loopCores(sys, function () {
    this.logger.trace(`clean for ${this}`)
    this.clean()
  })
}
