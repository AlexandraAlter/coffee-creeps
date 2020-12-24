import { getLogger } from './log'
import { RobotWorker } from './worker.robots'
import { State, TaskRet, TaskFunc, TaskLib } from './tasks'
import _ from 'lodash4'

const logger = getLogger('tasks.robots')
void logger

interface MoveState extends State {
  target: string
}

interface MoveArgs {
  target: RoomPosition
}

export const moveTask = new TaskFunc<RobotWorker, MoveState, MoveArgs>(
  'move',
  RobotWorker,

  (args) => {
    return {
      target: args.target.toString(),
    }
  },

  (worker, state) => {
    const pos = state.target
    logger.debug(worker.move(pos).toString())
    return TaskRet.OK
  }
)

export function registerAll(lib: TaskLib) {
  lib.register(moveTask)
}
