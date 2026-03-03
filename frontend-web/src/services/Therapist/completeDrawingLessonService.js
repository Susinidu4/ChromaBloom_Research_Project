// src/services/completeDrawingLesson.service.js

import axios from "axios";

const API_URL = import.meta.env.VITE_API_URL || "http://localhost:5000";
const BASE_ENDPOINT = "/chromabloom/completed-drawing-lessons";

const api = axios.create({
  baseURL: `${API_URL}${BASE_ENDPOINT}`,
  headers: {
    "Content-Type": "application/json",
  },
});

// Add auth interceptor if you have authentication
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem("token");
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

/**
 * Create a completed drawing lesson record
 * @param {Object} data - { lesson_id, user_id, correctness_rate (0-1 or 0-100) }
 * @returns {Promise<Object>} Created record or existing if duplicate
 */
export const createCompleteDrawingLesson = async (data) => {
  const response = await api.post("/", data);
  return response.data;
};

/**
 * Get all completed drawing lessons
 * @returns {Promise<Array>} List of all completed lessons
 */
export const getAllCompleteDrawingLessons = async () => {
  const response = await api.get("/");
  return response.data;
};

/**
 * Get a specific completed lesson by its ID (CLD-000x)
 * @param {string} id - Complete drawing lesson ID
 * @returns {Promise<Object>} Completed lesson details
 */
export const getCompleteDrawingLessonById = async (id) => {
  const response = await api.get(`/${id}`);
  return response.data;
};

/**
 * Get completed lessons by lesson ID and user ID
 * @param {string} lessonId - Lesson ID
 * @param {string} userId - User ID
 * @returns {Promise<Array>} List of completions for this user/lesson
 */
export const getCompleteDrawingLessonsByLessonIdAndUserId = async (
  lessonId,
  userId
) => {
  const response = await api.get(`/lesson/${lessonId}/user/${userId}`);
  return response.data;
};

/**
 * Check if a user has completed a specific lesson
 * @param {string} lessonId - Lesson ID
 * @param {string} userId - User ID
 * @returns {Promise<Object|null>} Completion record or null
 */
export const hasUserCompletedLesson = async (lessonId, userId) => {
  const response = await api.get(`/check/${lessonId}/${userId}`);
  return response.data;
};

/**
 * Get all completed lessons for a specific user
 * @param {string} userId - User ID
 * @returns {Promise<Array>} User's completed lessons
 */
export const getCompleteDrawingLessonsByUserId = async (userId) => {
  const response = await api.get(`/user/${userId}`);
  return response.data;
};

/**
 * Update a completed lesson record
 * @param {string} id - Complete drawing lesson ID
 * @param {Object} data - Fields to update
 * @returns {Promise<Object>} Updated record
 */
export const updateCompleteDrawingLesson = async (id, data) => {
  const response = await api.put(`/${id}`, data);
  return response.data;
};

/**
 * Delete a completed lesson record
 * @param {string} id - Complete drawing lesson ID
 * @returns {Promise<Object>} Success message
 */
export const deleteCompleteDrawingLesson = async (id) => {
  const response = await api.delete(`/${id}`);
  return response.data;
};

// Default export with all methods
const completeDrawingLessonService = {
  createCompleteDrawingLesson,
  getAllCompleteDrawingLessons,
  getCompleteDrawingLessonById,
  getCompleteDrawingLessonsByLessonIdAndUserId,
  hasUserCompletedLesson,
  getCompleteDrawingLessonsByUserId,
  updateCompleteDrawingLesson,
  deleteCompleteDrawingLesson,
};

export default completeDrawingLessonService;