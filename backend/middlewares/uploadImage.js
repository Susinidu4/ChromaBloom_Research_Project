// middlewares/uploadImage.js
import multer from "multer";
import path from "path";

const storage = multer.memoryStorage();

const ALLOWED_EXT = new Set([".jpg", ".jpeg", ".png", ".webp", ".bmp", ".gif"]);
const ALLOWED_MIME = new Set([
  "image/jpeg",
  "image/jpg",
  "image/png",
  "image/webp",
  "image/bmp",
  "image/gif",
  // Flutter sometimes sends this even for images:
  "application/octet-stream",
]);

const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter: (req, file, cb) => {
    const mimetype = (file.mimetype || "").toLowerCase();
    const ext = path.extname(file.originalname || "").toLowerCase();

    // ✅ Debug (temporarily keep while testing)
    // console.log("UPLOAD => mimetype:", mimetype, "name:", file.originalname);

    const mimeOk =
      mimetype.startsWith("image/") || ALLOWED_MIME.has(mimetype);

    const extOk = ALLOWED_EXT.has(ext);

    // Accept if:
    // 1) mimetype is image/*, OR
    // 2) mimetype is octet-stream but extension is an image
    if (mimeOk && (mimetype.startsWith("image/") || extOk)) {
      return cb(null, true);
    }

    return cb(new Error("Only image files are allowed"), false);
  },
});

export default upload;
