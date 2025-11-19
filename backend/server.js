import express from "express";
import dotenv from "dotenv";
import cors from "cors"; 
import connectDB from "./config/db.js";

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
app.get("/", (req, res) => {
  res.send("Hello from Node.js Backend!");
});

// Start server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
