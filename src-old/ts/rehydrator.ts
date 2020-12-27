import { getLogger } from './log'
import { Freq } from './freq'
import _ from 'lodash4'

const logger = getLogger('rehydrator')

export interface RehMem {
  cls: string
}

export interface RehBaseCls {
  new (...args: any[]): any
}

export interface RehCls {
  new (...args: any[]): this
  fullName: string
}

export class Rehydrator<
  Cls extends RehBaseCls,
  Mem extends RehMem,
  Args extends ConstructorParameters<Cls> = ConstructorParameters<Cls>
> {

  static toString(): string {
    return `[class ${this.name}]`
  }

  static makeFullName(cls: Function): string {
    return Object.getPrototypeOf(cls).name + '.' + cls.name
  }

  constructor(readonly instances: { [index: string]: RehBaseCls } = {}) {}

  toString(): string {
    return `[${this.constructor.name}]`
  }

  getCls(str: string): Function {
    const cls = this.instances[str]
    if (!cls) {
      throw Error(`instance ${str} not found`)
    }
    return cls
  }

  register<T extends Cls & RehCls>(cls: T) {
    this.instances[cls.fullName] = cls
  }

  from(mem: Mem, ...args: Args): any | undefined {
    const cls = this.instances[mem.cls]
    if (cls) {
      return new cls(...args)
    }
  }
}
