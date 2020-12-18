interface Console {
  log(message?: any, ...optionalParams: any[]): void
  commandResult(): void
  addVisual(): void
  getVisualSize(): void
  clearVisual(): void
  getVisual(): void
}

interface Error {
  stack?: string;
}

declare var global: NodeJS.Global;
declare var console: Console

interface NodeRequireFunction {
    (id: string): any
}

interface NodeRequire extends NodeRequireFunction {
    resolve: RequireResolve
    cache: any
    extensions: NodeExtensions
    main: NodeModule | undefined
}

interface RequireResolve {
    (id: string, options?: { paths?: string[]; }): string
    paths(request: string): string[] | null
}

interface NodeExtensions {
    '.js': (m: NodeModule, filename: string) => any
    '.json': (m: NodeModule, filename: string) => any
    '.node': (m: NodeModule, filename: string) => any
    [ext: string]: (m: NodeModule, filename: string) => any
}

declare var require: NodeRequire

interface NodeModule {
    exports: any;
    require: NodeRequireFunction;
    id: string;
    filename: string;
    loaded: boolean;
    parent: NodeModule | null;
    children: NodeModule[];
    paths: string[];
}

declare var module: NodeModule;

declare var exports: any;

type BufferEncoding = "ascii" | "utf8" | "utf16le" | "ucs2" | "base64" | "latin1" | "binary" | "hex";
interface Buffer extends Uint8Array {
    constructor: typeof Buffer;
    write(string: string, offset?: number, length?: number, encoding?: string): number;
    toString(encoding?: string, start?: number, end?: number): string;
    toJSON(): { type: 'Buffer', data: any[] };
    equals(otherBuffer: Uint8Array): boolean;
    compare(otherBuffer: Uint8Array, targetStart?: number, targetEnd?: number, sourceStart?: number, sourceEnd?: number): number;
    copy(targetBuffer: Uint8Array, targetStart?: number, sourceStart?: number, sourceEnd?: number): number;
    slice(start?: number, end?: number): Buffer;
    writeUIntLE(value: number, offset: number, byteLength: number, noAssert?: boolean): number;
    writeUIntBE(value: number, offset: number, byteLength: number, noAssert?: boolean): number;
    writeIntLE(value: number, offset: number, byteLength: number, noAssert?: boolean): number;
    writeIntBE(value: number, offset: number, byteLength: number, noAssert?: boolean): number;
    readUIntLE(offset: number, byteLength: number, noAssert?: boolean): number;
    readUIntBE(offset: number, byteLength: number, noAssert?: boolean): number;
    readIntLE(offset: number, byteLength: number, noAssert?: boolean): number;
    readIntBE(offset: number, byteLength: number, noAssert?: boolean): number;
    readUInt8(offset: number, noAssert?: boolean): number;
    readUInt16LE(offset: number, noAssert?: boolean): number;
    readUInt16BE(offset: number, noAssert?: boolean): number;
    readUInt32LE(offset: number, noAssert?: boolean): number;
    readUInt32BE(offset: number, noAssert?: boolean): number;
    readInt8(offset: number, noAssert?: boolean): number;
    readInt16LE(offset: number, noAssert?: boolean): number;
    readInt16BE(offset: number, noAssert?: boolean): number;
    readInt32LE(offset: number, noAssert?: boolean): number;
    readInt32BE(offset: number, noAssert?: boolean): number;
    readFloatLE(offset: number, noAssert?: boolean): number;
    readFloatBE(offset: number, noAssert?: boolean): number;
    readDoubleLE(offset: number, noAssert?: boolean): number;
    readDoubleBE(offset: number, noAssert?: boolean): number;
    swap16(): Buffer;
    swap32(): Buffer;
    swap64(): Buffer;
    writeUInt8(value: number, offset: number, noAssert?: boolean): number;
    writeUInt16LE(value: number, offset: number, noAssert?: boolean): number;
    writeUInt16BE(value: number, offset: number, noAssert?: boolean): number;
    writeUInt32LE(value: number, offset: number, noAssert?: boolean): number;
    writeUInt32BE(value: number, offset: number, noAssert?: boolean): number;
    writeInt8(value: number, offset: number, noAssert?: boolean): number;
    writeInt16LE(value: number, offset: number, noAssert?: boolean): number;
    writeInt16BE(value: number, offset: number, noAssert?: boolean): number;
    writeInt32LE(value: number, offset: number, noAssert?: boolean): number;
    writeInt32BE(value: number, offset: number, noAssert?: boolean): number;
    writeFloatLE(value: number, offset: number, noAssert?: boolean): number;
    writeFloatBE(value: number, offset: number, noAssert?: boolean): number;
    writeDoubleLE(value: number, offset: number, noAssert?: boolean): number;
    writeDoubleBE(value: number, offset: number, noAssert?: boolean): number;
    fill(value: any, offset?: number, end?: number): this;
    indexOf(value: string | number | Uint8Array, byteOffset?: number, encoding?: string): number;
    lastIndexOf(value: string | number | Uint8Array, byteOffset?: number, encoding?: string): number;
    entries(): IterableIterator<[number, number]>;
    includes(value: string | number | Buffer, byteOffset?: number, encoding?: string): boolean;
    keys(): IterableIterator<number>;
    values(): IterableIterator<number>;
}

declare const Buffer: {
    new(str: string, encoding?: string): Buffer;
    new(size: number): Buffer;
    new(array: Uint8Array): Buffer;
    new(arrayBuffer: ArrayBuffer | SharedArrayBuffer): Buffer;
    new(array: ReadonlyArray<any>): Buffer;
    new(buffer: Buffer): Buffer;
    prototype: Buffer;
    from(arrayBuffer: ArrayBuffer | SharedArrayBuffer, byteOffset?: number, length?: number): Buffer;
    from(data: ReadonlyArray<any>): Buffer;
    from(data: Uint8Array): Buffer;
    from(obj: { valueOf(): string | object } | { [Symbol.toPrimitive](hint: 'string'): string }, byteOffset?: number, length?: number): Buffer;
    from(str: string, encoding?: string): Buffer;
    of(...items: number[]): Buffer;
    isBuffer(obj: any): obj is Buffer;
    isEncoding(encoding: string): boolean | undefined;
    byteLength(string: string | NodeJS.TypedArray | DataView | ArrayBuffer | SharedArrayBuffer, encoding?: string): number;
    concat(list: ReadonlyArray<Uint8Array>, totalLength?: number): Buffer;
    compare(buf1: Uint8Array, buf2: Uint8Array): number;
    alloc(size: number, fill?: string | Buffer | number, encoding?: string): Buffer;
    allocUnsafe(size: number): Buffer;
    allocUnsafeSlow(size: number): Buffer;
    poolSize: number;
};

declare namespace NodeJS {

  interface Global {
    Array: typeof Array;
    ArrayBuffer: typeof ArrayBuffer;
    Boolean: typeof Boolean;
    Buffer: typeof Buffer;
    DataView: typeof DataView;
    Date: typeof Date;
    Error: typeof Error;
    EvalError: typeof EvalError;
    Float32Array: typeof Float32Array;
    Float64Array: typeof Float64Array;
    Function: typeof Function;
    GLOBAL: Global;
    Infinity: typeof Infinity;
    Int16Array: typeof Int16Array;
    Int32Array: typeof Int32Array;
    Int8Array: typeof Int8Array;
    Intl: typeof Intl;
    JSON: typeof JSON;
    Map: MapConstructor;
    Math: typeof Math;
    NaN: typeof NaN;
    Number: typeof Number;
    Object: typeof Object;
    Promise: Function;
    RangeError: typeof RangeError;
    ReferenceError: typeof ReferenceError;
    RegExp: typeof RegExp;
    Set: SetConstructor;
    String: typeof String;
    Symbol: Function;
    SyntaxError: typeof SyntaxError;
    TypeError: typeof TypeError;
    URIError: typeof URIError;
    Uint16Array: typeof Uint16Array;
    Uint32Array: typeof Uint32Array;
    Uint8Array: typeof Uint8Array;
    Uint8ClampedArray: Function;
    WeakMap: WeakMapConstructor;
    WeakSet: WeakSetConstructor;
    console: typeof console;
    decodeURI: typeof decodeURI;
    decodeURIComponent: typeof decodeURIComponent;
    encodeURI: typeof encodeURI;
    encodeURIComponent: typeof encodeURIComponent;
    escape: (str: string) => string;
    eval: typeof eval;
    global: Global;
    isFinite: typeof isFinite;
    isNaN: typeof isNaN;
    parseFloat: typeof parseFloat;
    parseInt: typeof parseInt;
    undefined: typeof undefined;
    unescape: (str: string) => string;
  }

  class Module {
      static runMain(): void;
      static wrap(code: string): string;
      static createRequireFromPath(path: string): (path: string) => any;
      static builtinModules: string[];

      static Module: typeof Module;

      exports: any;
      require: NodeRequireFunction;
      id: string;
      filename: string;
      loaded: boolean;
      parent: Module | null;
      children: Module[];
      paths: string[];

      constructor(id: string, parent?: Module);
  }

  type TypedArray =
      | Uint8Array
      | Uint8ClampedArray
      | Uint16Array
      | Uint32Array
      | Int8Array
      | Int16Array
      | Int32Array
      | BigUint64Array
      | BigInt64Array
      | Float32Array
      | Float64Array;
  type ArrayBufferView = TypedArray | DataView;
}
