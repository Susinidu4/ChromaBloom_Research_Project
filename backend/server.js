import express from "express";
import dotenv from "dotenv";
import cors from "cors"; 
import connectDB from "./config/db.js";
// user management
import adminRoutes from "./routes/Users/admin.routes.js";
import caregiverRoutes from "./routes/Users/caregiver.routes.js";
import childRoutes from "./routes/Users/child.routes.js"
import therapistRoutes from "./routes/Users/therapist.routes.js";
// routine management
import routine from "./routes/Interactive_Visual_Task_Scheduler_Route/routine.js";
// parental stress monitoring
import journalEntryRoutes from "./routes/Parent_Stress_Monitoring_Route/journalEntry.js";

dotenv.config();

const app = express();

app.use(cors(
  {
    origin: true,
  }
));

// Middleware
app.use(express.json());

// Connect to Database
connectDB();

// Routes
// User Management
app.use("/chromabloom/api/admins", adminRoutes);
app.use("/api/caregivers", caregiverRoutes);
app.use("/api/children", childRoutes);
app.use("/api/therapists", therapistRoutes);

// Routine Management
app.use("/chromabloom/routine", routine);

// Parent Stress Monitoring 
app.use("/chromabloom/journalEntries", journalEntryRoutes);

// Start server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
