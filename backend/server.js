import express from "express";
import dotenv from "dotenv";
import cors from "cors"; 
import connectDB from "./config/db.js";
import adminRoutes from "./routes/Users/admin.routes.js";
import caregiverRoutes from "./routes/Users/caregiver.routes.js";
import routine from "./routes/Interactive_Visual_Task_Scheduler_Route/routine.js";

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

// Test Route
app.use("/chromabloom/routine", routine);

// Routes
app.use("/chromabloom/api/admins", adminRoutes);
app.use("/api/caregivers", caregiverRoutes);

// Start server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
