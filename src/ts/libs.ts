export interface Refable {
  ref: string
  kind: Function
}

export interface Lib<T extends Refable> {
  [index: string]: T | unknown | undefined
  toString(): string
}

export class Lib<T> {
  public static toString(): string {
    return `[class ${this.name}]`
  }

  public toString(): string {
    return `[${this.constructor.name}]`
  }

  public register(val: T) {
    if (val.ref in Lib.prototype) {
      throw Error(`ref ${val.ref} would override prototype in lib`)
    }
    if (val.ref in this) {
      throw Error(`ref ${val.ref} would duplicate an entry in lib`)
    }
    this[val.ref] = val
  }

  public list(kind?: Function): T[] {
    const ret = []
    for (const n in this) {
      if (n in Lib.prototype) {
        continue
      }
      const val = this[n] as T
      if (val && (!kind || val.kind instanceof kind)) {
        ret.push(val)
      }
    }
    return ret
  }

  public get(ref: string, kind?: Function): T | undefined {
    if (ref in Lib.prototype) {
      throw Error(`${ref} is a prototype in lib`)
    }
    const val = this[ref] as T
    if (!val) {
      throw Error(`${ref} not found in lib`)
    }
    if (kind && !(val.kind instanceof kind)) {
      throw Error(`found task for ${ref} is for ${val.kind}, not ${kind}`)
    }
    return val
  }
}
