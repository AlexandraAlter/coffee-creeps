# Screeps

## Design

### Core Layer

- Direct commands within one tick
- Sanitization of underlying code
- Utility classes for Memory, Backing classes, Backoffs, Frequencies

### RTS Layer

- Direct commands persisting over ticks
- Implemented by a Worker system, Tasks, CAsm

### Sim Layer

- Indirect commands relating to desired game state
- Implemented through a Brain/Cortex/Node system

