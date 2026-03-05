import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:5000';

const cognitiveProgressApi = axios.create({
  baseURL: `${API_BASE_URL}/chromabloom/cognitiveProgress_2`,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 10000,
});

// Request interceptor for auth tokens (if needed)
cognitiveProgressApi.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('authToken');
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
 * Create new progress prediction
 * @param {Object} payload - { userId: string, progress_prediction: number }
 * @returns {Promise<{success: boolean, data: Object}>}
 */
export const createProgress = async (payload) => {
  const response = await cognitiveProgressApi.post('/', payload);
  return response.data;
};

/**
 * Update progress prediction
 * @param {string} id - The progress record ID
 * @param {Object} payload - { userId?: string, progress_prediction?: number }
 * @returns {Promise<{success: boolean, data: Object}>}
 */
export const updateProgress = async (id, payload) => {
  const response = await cognitiveProgressApi.put(`/${id}`, payload);
  return response.data;
};

/**
 * Delete progress prediction
 * @param {string} id - The progress record ID
 * @returns {Promise<{success: boolean, message: string, data: Object}>}
 */
export const deleteProgress = async (id) => {
  const response = await cognitiveProgressApi.delete(`/${id}`);
  return response.data;
};

/**
 * Get prediction from Python ML service (via Node proxy)
 * @param {Object} features - Required feature object
 * @param {number} [top_k=10] - Number of top factors to return
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
  getProgressByUserId,
  getAllProgress,
  getProgressById,
  createProgress,
  updateProgress,
  deleteProgress,
  predictProgress,
};