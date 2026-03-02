// src/services/completeProblemSolvingSessionService.js

import axios from 'axios';

// Base API URL - adjust according to your backend
const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000/api';

const api = axios.create({
    baseURL: `${API_BASE_URL}/complete-problem-solving-sessions`,
    headers: {
        'Content-Type': 'application/json',
    },
});

// Request interceptor for auth tokens
api.interceptors.request.use(
    (config) => {
        const token = localStorage.getItem('token');
        if (token) {
            config.headers.Authorization = `Bearer ${token}`;
        }
        return config;
    },
    (error) => Promise.reject(error)
);

// Response interceptor for error handling
api.interceptors.response.use(
    (response) => response,
    (error) => {
        const customError = {
            message: error.response?.data?.message || 'An error occurred',
            status: error.response?.status,
            data: error.response?.data,
        };
        return Promise.reject(customError);
    }
);

/**
 * ✅ CREATE - Create a new complete problem solving session
 * @param {Object} sessionData - Session data
 * @param {string} sessionData.childId - Child ID
 * @param {Array<string>} sessionData.lessons - Array of lesson IDs
 * @param {number} [sessionData.correctness_score=0] - Correctness score
 * @returns {Promise<Object>} Created session
 */
export const createCompleteProblemSolvingSession = async (sessionData) => {
    try {
        const response = await api.post('/', sessionData);
        return {
            success: true,
            data: response.data,
            message: 'Session created successfully',
        };
    } catch (error) {
        return {
            success: false,
            error: error.message,
            status: error.status,
        };
    }
};

/**
 * ✅ GET BY ID - Fetch session by ID
 * @param {string} id - Session ID
 * @returns {Promise<Object>} Session data with populated child and lessons
 */
export const getCompleteProblemSolvingSessionById = async (id) => {
    try {
        const response = await api.get(`/${id}`);
        return {
            success: true,
            data: response.data,
        };
    } catch (error) {
        return {
            success: false,
            error: error.message,
            status: error.status,
        };
    }
};

/**
 * ✅ GET BY CHILD + LESSON - Fetch sessions by child and lesson
 * @param {string} childId - Child ID
 * @param {string} lessonId - Lesson ID
 * @returns {Promise<Object>} Sessions array with count
 */
export const getSessionsByChildAndLesson = async (childId, lessonId) => {
    try {
        const response = await api.get(`/child/${childId}/lesson/${lessonId}`);
        return {
            success: true,
            data: response.data.data,
            count: response.data.count,
        };
    } catch (error) {
        return {
            success: false,
            error: error.message,
            status: error.status,
        };
    }
};

/**
 * ✅ UPDATE - Update session by ID
 * @param {string} id - Session ID
 * @param {Object} updateData - Fields to update
 * @param {string} [updateData.childId] - Child ID
 * @param {Array<string>} [updateData.lessons] - Array of lesson IDs
 * @param {number} [updateData.correctness_score] - Correctness score
 * @returns {Promise<Object>} Updated session
 */
export const updateCompleteProblemSolvingSession = async (id, updateData) => {
    try {
        const response = await api.put(`/${id}`, updateData);
        return {
            success: true,
            data: response.data,
            message: 'Session updated successfully',
        };
    } catch (error) {
        return {
            success: false,
            error: error.message,
            status: error.status,
        };
    }
};

/**
 * ✅ DELETE - Delete session by ID
 * @param {string} id - Session ID
 * @returns {Promise<Object>} Deletion confirmation
 */
export const deleteCompleteProblemSolvingSession = async (id) => {
    try {
        const response = await api.delete(`/${id}`);
        return {
            success: true,
            data: response.data,
            message: 'Session deleted successfully',
        };
    } catch (error) {
        return {
            success: false,
            error: error.message,
            status: error.status,
        };
    }
};

/**
 * 🎯 Custom Hook for React Components
 * Returns all service methods and loading states
 */
export const useCompleteProblemSolvingSessionService = () => {
    return {
        create: createCompleteProblemSolvingSession,
        getById: getCompleteProblemSolvingSessionById,
        getByChildAndLesson: getSessionsByChildAndLesson,
        update: updateCompleteProblemSolvingSession,
        delete: deleteCompleteProblemSolvingSession,
    };
};

export default {
    createCompleteProblemSolvingSession,
    getCompleteProblemSolvingSessionById,
    getSessionsByChildAndLesson,
    updateCompleteProblemSolvingSession,
    deleteCompleteProblemSolvingSession,
    useCompleteProblemSolvingSessionService,
};