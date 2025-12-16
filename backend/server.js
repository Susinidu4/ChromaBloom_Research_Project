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
import userActivityRoutes from "./routes/Interactive_Visual_Task_Scheduler_Route/userActivityRoute.js";
import systemActivityRoutes from "./routes/Interactive_Visual_Task_Scheduler_Route/systemActivityRoute.js";
// parental stress monitoring
import journalEntryRoutes from "./routes/Parent_Stress_Monitoring_Route/journalEntry.js";

// gemified knowledge builder
import drawingLessonRoutes from "./routes/Gemified_Knowlage_Builder_Route/drawingLessonRoutes.js";
import problemSolvingLessonRoutes from "./routes/Gemified_Knowlage_Builder_Route/problemSolvingLessonRoutes.js";
import completeDrawingLessonRoutes from "./routes/Gemified_Knowlage_Builder_Route/completeDrawingLessonRoutes.js";
import completeProblemSolvingSessionRoutes from "./routes/Gemified_Knowlage_Builder_Route/completeProblemSolvingSessonRoutes.js";

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
app.use("/chromabloom/userActivities", userActivityRoutes);
app.use("/chromabloom/systemActivities", systemActivityRoutes);
// Parent Stress Monitoring 
app.use("/chromabloom/journalEntries", journalEntryRoutes);
// Gemified Knowledge Builder
app.use("/chromabloom/drawing-lessons", drawingLessonRoutes);
app.use("/chromabloom/problem-solving-lessons", problemSolvingLessonRoutes);
app.use("/chromabloom/completed-drawing-lessons", completeDrawingLessonRoutes);
app.use("/chromabloom/complete-problem-solving-sessions", completeProblemSolvingSessionRoutes);

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
