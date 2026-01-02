import JournalEntry from "../../models/Parental_Stress_Monitoring_Model/journalEntryModel.js";


// Simple rule-based sentiment scorer (-1 to +1)
const calculateSentiment = (text = "") => {
  const t = text.toLowerCase();

  const negativeWords = [
    "tired", "exhausted", "stressed", "overwhelmed", "angry", "sad",
    "worried", "anxious", "frustrated", "hopeless", "burnout"
  ];

  const positiveWords = [
    "happy", "calm", "relieved", "good", "better", "peaceful",
    "grateful", "thankful", "proud", "hopeful"
  ];

  let score = 0;

  for (const w of negativeWords) {
    if (t.includes(w)) score -= 0.2;
  }
  for (const w of positiveWords) {
    if (t.includes(w)) score += 0.2;
  }

  // clamp to [-1, 1] and round for neat storage
  score = Math.max(-1, Math.min(1, score));
  return Math.round(score * 1000) / 1000;
};
// Create a new journal entry
export const createJournalEntry = async (req, res) => {
  try {
    const { caregiver_ID, mood, moodEmoji, text } = req.body;

    // validate required fields
    if (!caregiver_ID || !mood || !moodEmoji || !text) {
      return res.status(400).json({ error: "caregiver_ID, mood, moodEmoji and text are required" });
    }

    // optional: ensure mood is valid (matches schema enum)
    const allowedMoods = ["happy", "calm", "neutral", "tired", "sad", "angry", "stressed"];
    if (!allowedMoods.includes(mood)) {
      return res.status(400).json({ error: "Invalid mood value" });
    }

    
    // compute sentiment from journal text
    const journal_sentiment = calculateSentiment(text);

    const newEntry = new JournalEntry({
      caregiver_ID,
      mood,
      moodEmoji,
      text,
      journal_sentiment,
    });

    const savedEntry = await newEntry.save();

    return res.status(201).json({
      message: "Journal entry created successfully",
      data: savedEntry,
    });
  } catch (error) {
    return res.status(500).json({
      message: "Internal server error",
      error: error.message,
    });
  }
};

// Get journal entries by caregiver ID
export const getJournalEntriesByCaregiver = async (req, res) => {
  try {
    const { caregiver_ID } = req.params;

    if (!caregiver_ID) {
      return res.status(400).json({ error: "Caregiver ID is required" });
    }
    const entries = await JournalEntry.find({ caregiver_ID }).sort({
      created_at: -1,
    });

    return res.status(200).json({
      message: "Journal entries retrieved successfully",
      data: entries,
    });
  } catch (error) {
    return res.status(500).json({
      message: "Internal server error",
      error: error.message,
    });
  }
};

// Delete a journal entry by ID
export const deleteJournalEntry = async (req, res) => {
  try {
    const { entry_ID } = req.params;

    if (!entry_ID) {
      return res.status(400).json({ error: "Entry ID is required" });
    }

    const deletedEntry = await JournalEntry.findByIdAndDelete(entry_ID);

    if (!deletedEntry) {
      return res.status(404).json({ error: "Journal entry not found" });
    }

    return res.status(200).json({
      message: "Journal entry deleted successfully",
      data: deletedEntry,
    });
  } catch (error) {
    return res.status(500).json({
      message: "Internal server error",
      error: error.message,
    });
  }
};

// Update a journal entry by ID
export const updateJournalEntry = async (req, res) => {
  try {
    const { entry_ID } = req.params;

    if (!entry_ID) {
      return res.status(400).json({ error: "Entry ID is required" });
    }

    const updateData = req.body;
    // If mood is provided, validate enum manually (optional safety)
    const allowedMoods = [
      "happy",
      "calm",
      "neutral",
      "tired",
      "sad",
      "angry",
      "stressed",
    ];
    if (updateData.mood && !allowedMoods.includes(updateData.mood)) {
      return res.status(400).json({ error: "Invalid mood value" });
    }

    // ✅ if text is updated, recompute sentiment
    if (typeof updateData.text === "string" && updateData.text.trim().length > 0) {
      updateData.journal_sentiment = calculateSentiment(updateData.text);
    }

    // Update the journal entry
    const updatedEntry = await JournalEntry.findByIdAndUpdate(
      entry_ID,
      updateData,
      {
        new: true,          // return updated version
        runValidators: true // apply schema validation
      }
    );

    if (!updatedEntry) {
      return res.status(404).json({ error: "Journal entry not found" });
    }

    return res.status(200).json({
      message: "Journal entry updated successfully",
      data: updatedEntry,
    });

  } catch (error) {
    return res.status(500).json({
      message: "Internal server error",
      error: error.message,
    });
  }
};
