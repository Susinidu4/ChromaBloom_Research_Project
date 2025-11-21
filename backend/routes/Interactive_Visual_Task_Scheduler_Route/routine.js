import express from 'express';
import { createRoutine } from '../../controllers/Interactive_Visual_Task_Scheduler_Controller/routine.js';

const router = express.Router();

router.post('/create', createRoutine);

export default router;