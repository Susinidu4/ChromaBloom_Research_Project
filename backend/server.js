import express from "express";
import dotenv from "dotenv";
import cors from "cors";
import connectDB from "./config/db.js";

// user management
import adminRoutes from "./routes/Users/adminRoutes.js";
import caregiverRoutes from "./routes/Users/caregiverRoutes.js";
import childRoutes from "./routes/Users/childRoutes.js";
import therapistRoutes from "./routes/Users/therapistRoutes.js";
// routine management
import routine from "./routes/Interactive_Visual_Task_Scheduler_Route/routine.js";
// parental stress monitoring
import journalEntryRoutes from "./routes/Parent_Stress_Monitoring_Route/journalEntry.js";

dotenv.config();

const app = express();

// MIDDLEWARE
// CORS
app.use(
  cors({
    origin: true,
  })
);

// ✅ Single JSON/body parser with LARGE limit
//   (remove all other express.json / body-parser uses)
app.use(express.json({ limit: "50mb" }));
app.use(express.urlencoded({ extended: true, limit: "50mb" }));

//  DB CONNECTION
connectDB();

// Routes
// User Management
app.use("/chromabloom/admins", adminRoutes);
app.use("/chromabloom/caregivers", caregiverRoutes);
app.use("/chromabloom/children", childRoutes);
app.use("/chromabloom/therapists", therapistRoutes);
// Routine Management
app.use("/chromabloom/routine", routine);
// Parent Stress Monitoring 
app.use("/chromabloom/journalEntries", journalEntryRoutes);

//  ERROR HANDLER (JSON, not HTML)
app.use((err, req, res, next) => {
  console.error("🔥 Global error handler:", err.message);

  if (err.type === "entity.too.large") {
    return res.status(413).json({
      success: false,
      message: "Request payload too large. Please use a smaller image.",
    });
  }

  return res.status(500).json({
    success: false,
    message: err.message || "Server error",
  });
});

// Start server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
