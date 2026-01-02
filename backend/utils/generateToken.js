import jwt from "jsonwebtoken";

export const generateToken = (admin) => {
  return jwt.sign(
    { id: admin._id },
    process.env.JWT_SECRET,
    { expiresIn: "7d" }
  );
};
