import mongoose from "mongoose";

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log(`MongoDB connected: ${conn.connection.host}`);
    console.log(`Database: ${conn.connection.name}`);
    console.log("✅ MongoDB successfully connected!");

  } catch (error) {

    console.error("❌ MongoDB connection failed!");
    console.error(`Error: ${error.message}`);
    process.exit(1); // Exit process with failure
 
  }
};

export default connectDB;
