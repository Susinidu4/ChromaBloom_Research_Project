import express from 'express';
import { createRoutine, getRoutineByCreator, getRoutineById, updateRoutine, deleteRoutine } from '../../controllers/Interactive_Visual_Task_Scheduler_Controller/routine.js';

const router = express.Router();

router.post('/create', createRoutine);

router.get('/getRoutine/:created_by', getRoutineByCreator);

router.get('/getRoutineById/:routineId', getRoutineById);

router.put('/updateRoutine/:routineId', updateRoutine);

router.delete('/deleteRoutine/:routineId', deleteRoutine);

export default router;