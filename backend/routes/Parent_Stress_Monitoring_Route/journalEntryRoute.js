import express from "express";
import { createJournalEntry, getJournalEntriesByCaregiver, deleteJournalEntry, updateJournalEntry } from "../../controllers/Parental_Stress_Monitoring_Controller/journalEntryController.js";

const router = express.Router();


// Create a new journal entry
// POST /chromabloom/journalEntries/createJournal
router.post("/createJournal" , createJournalEntry);

// Get journal entries by caregiver ID
// GET /chromabloom/journalEntries/getJournal/:caregiver_ID
router.get("/getJournal/:caregiver_ID" , getJournalEntriesByCaregiver);

// Delete a journal entry by entry ID
// DELETE /chromabloom/journalEntries/deleteJournal/:entry_ID
router.delete("/deleteJournal/:entry_ID" , deleteJournalEntry);

// Update a journal entry by entry ID
// PUT /chromabloom/journalEntries/updateJournal/:entry_ID
router.put("/updateJournal/:entry_ID" , updateJournalEntry);

export default router;