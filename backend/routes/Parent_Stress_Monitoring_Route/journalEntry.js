import express from "express";
import { createJournalEntry, getJournalEntriesByCaregiver, deleteJournalEntry, updateJournalEntry } from "../../controllers/Parental_Stress_Monitoring_Controller/journalEntry.js";

const router = express.Router();

router.post("/createJournal" , createJournalEntry);

router.get("/getJournal/:caregiver_ID" , getJournalEntriesByCaregiver);

router.delete("/deleteJournal/:entry_ID" , deleteJournalEntry);

router.put("/updateJournal/:entry_ID" , updateJournalEntry);

export default router;