import multer from "multer";

const storage = multer.memoryStorage();

const uploadVideo = multer({
  storage,
  limits: { fileSize: 50 * 1024 * 1024 }, // 50MB
});

export default uploadVideo;
