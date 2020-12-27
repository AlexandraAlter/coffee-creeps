import { getLogger } from './log'
import _ from 'lodash4'

const logger = getLogger('backing')

export interface Backing<Core, Back> {
  constructor: Function & {
    prototype: Back
  }
  core?: Core
}

export type AnyBacking = Backing<any, any>

export class BackingProxy<Back extends AnyBacking> {
  public static toString(): string {
    return `[class ${this.name}]`
  }

  protected static logger = logger

  private cache: Back | null = null

  public constructor(
    private getBacking: () => Back,
    private cleanup: () => void,
  ) {}

  public get(): Back | undefined {
    if (this.cache) {
      return this.cache
    }
    const bak = this.getBacking()
    if (!bak) {
      this.cleanup()
    }
    return this.cache = bak
  }

  public clean(): void {
    this.cache = null
  }

  public exists(): boolean {
    return typeof this.get() !== 'undefined'
  }
}

export interface BackingProxyInt extends BackingProxy<any> {}
