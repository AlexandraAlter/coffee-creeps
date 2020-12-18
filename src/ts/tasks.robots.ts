import { getLogger } from './log'
import { RobotWorker } from './worker.robots'
import { State, TaskRet, TaskFunc, TaskLib } from './tasks'
import _ from 'lodash'

const logger = getLogger('tasks.robots')

interface MoveState extends State {}
interface MoveArgs {}

const moveTask = new TaskFunc<RobotWorker, MoveState, MoveArgs>(
  'move',
  RobotWorker,
  (args) => ({} as MoveState),
  (worker, state) => {
    return TaskRet.OK
  },
)

export function registerAll(lib: TaskLib) {
  lib.register(moveTask)
}
