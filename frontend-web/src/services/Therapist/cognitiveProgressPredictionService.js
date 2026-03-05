import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:5000';

/**
 * Feature set required by the Cognitive Progress Prediction ML model.
 * Aligning with the backend route and controller definitions.
 */
export const COGNITIVE_PROGRESS_FEATURES = [
  "gender",
  "diagnosis_type",
  "activity",
  "mood_label",
  "caregiver_mood_label",
  "age",
  "time_duration_for_activity",
  "sentiment_score",
  "stress_score_combined",
  "phone_screen_time_mins",
  "sleep_hours",
  "total_tasks_assigned",
  "total_tasks_completed",
  "completion_rate",
  "engagement_minutes",
  "memory_accuracy",
  "attention_accuracy",
  "problem_solving_accuracy",
  "motor_skills_accuracy",
  "average_response_time",
  "caregiver_sentiment_score",
  "caregiver_stress_score_combined",
  "caregiver_phone_screen_time_mins",
  "caregiver_sleep_hours",
];

const cognitiveProgressApi = axios.create({
  baseURL: `${API_BASE_URL}/chromabloom/cognitiveProgress_2`,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 10000,
});

// Request interceptor for auth tokens
cognitiveProgressApi.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('authToken') || localStorage.getItem('therapist_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor for error handling
cognitiveProgressApi.interceptors.response.use(
  (response) => response,
  (error) => {
    const customError = {
      message: error.response?.data?.message || error.message,
      status: error.response?.status,
      data: error.response?.data,
    };
    return Promise.reject(customError);
  }
);

/**
 * Get cognitive progress predictions by user ID
 * @param {string} userId - The user/child ID to fetch progress for
 * @returns {Promise<{success: boolean, count: number, data: Array}>}
 */
export const getProgressByUserId = async (userId) => {
  if (!userId) {
    throw new Error('userId is required');
  }
  const response = await cognitiveProgressApi.get(`/user/${userId}`);
  return response.data;
};

/**
 * Get all cognitive progress records
 * @returns {Promise<{success: boolean, count: number, data: Array}>}
 */
export const getAllProgress = async () => {
  const response = await cognitiveProgressApi.get('/');
  return response.data;
};

/**
 * Get single progress record by ID
 * @param {string} id - The progress record ID
 * @returns {Promise<{success: boolean, data: Object}>}
 */
export const getProgressById = async (id) => {
  const response = await cognitiveProgressApi.get(`/${id}`);
  return response.data;
};

/**
 * Create new progress prediction record in DB
 * @param {Object} payload - { userId, progress_prediction, positive_factors, negative_factors }
 * @returns {Promise<{success: boolean, data: Object}>}
 */
export const createProgress = async (payload) => {
  const response = await cognitiveProgressApi.post('/', payload);
  return response.data;
};

/**
 * Update progress prediction record
 * @param {string} id - The progress record ID
 * @param {Object} payload - Fields to update
 * @returns {Promise<{success: boolean, data: Object}>}
 */
export const updateProgress = async (id, payload) => {
  const response = await cognitiveProgressApi.put(`/${id}`, payload);
  return response.data;
};

/**
 * Delete progress prediction record
 * @param {string} id - The progress record ID
 */
export const deleteProgress = async (id) => {
  const response = await cognitiveProgressApi.delete(`/${id}`);
  return response.data;
};

/**
 * Generate a prediction from Python ML service via Node proxy
 * @param {Object} features - Object containing values for all required feature fields
 * @param {number} [top_k=10] - Number of top factors to return for explainability
 * @returns {Promise<{message: string, result: Object}>}
 */
export const predictProgress = async (features, top_k = 10) => {
  const response = await cognitiveProgressApi.post('/predict-progress', {
    features,
    top_k,
  });
  return response.data;
};

export default {
  COGNITIVE_PROGRESS_FEATURES,
  getProgressByUserId,
  getAllProgress,
  getProgressById,
  createProgress,
  updateProgress,
  deleteProgress,
  predictProgress,
};
