import express from 'express';
import upload from "../../middlewares/uploadImage.js";
import { createRoutine, getRoutineByCreator, getRoutineById, updateRoutine, deleteRoutine } from '../../controllers/Interactive_Visual_Task_Scheduler_Controller/routine.js';

const router = express.Router();

router.post('/create',upload.single("routine_image"), createRoutine);

router.get('/getRoutine/:created_by', getRoutineByCreator);

router.get('/getRoutineById/:routineId', getRoutineById);

router.put('/updateRoutine/:routineId', updateRoutine);

router.delete('/deleteRoutine/:routineId', deleteRoutine);

export default router;