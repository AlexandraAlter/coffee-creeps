import { getLogger } from './log'
import { RobotWorker } from './worker.robots'
import { State, TaskRet, TaskFunc, TaskLib } from './tasks'
import _ from 'lodash4'

const logger = getLogger('tasks.robots')
void logger

interface MoveState extends State {
  target: RoomPosition
}
interface MoveArgs {
  target: _HasRoomPosition
}

const moveTask = new TaskFunc<RobotWorker, MoveState, MoveArgs>(
  'move',
  RobotWorker,

  (args) => {
    return {
      target: args.target.pos,
    }
  },

  (worker, state) => {
    logger.debug(worker.move(state.target).toString())
    return TaskRet.OK
  }
)

export function registerAll(lib: TaskLib) {
  lib.register(moveTask)
}
