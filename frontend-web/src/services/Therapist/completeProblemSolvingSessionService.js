import axios from "axios";

const API_BASE_URL = "http://localhost:5000/chromabloom/complete-problem-solving-sessions";

// CREATE SESSION
export const createCompleteProblemSolvingSession = async (data) => {
    try {
        const response = await axios.post(`${API_BASE_URL}/`, data);
        return response.data;
    } catch (error) {
        throw error.response?.data || { message: "Failed to create session" };
    }
};

// GET SESSION BY ID
export const getCompleteProblemSolvingSessionById = async (id) => {
    try {
        const response = await axios.get(`${API_BASE_URL}/${id}`);
        return response.data;
    } catch (error) {
        throw error.response?.data || { message: "Failed to fetch session" };
    }
};

// GET SESSION BY USER ID
export const getCompleteProblemSolvingSessionByUserId = async (userId) => {
    try {
        const response = await axios.get(`${API_BASE_URL}/user/${userId}`);
        return response.data;
    } catch (error) {
        throw error.response?.data || { message: "Failed to fetch sessions by user" };
    }
};

// GET SESSION BY CHILD + LESSON
export const getByChildAndLesson = async (childId, lessonId) => {
    try {
        const response = await axios.get(
            `${API_BASE_URL}/by-child-lesson/${childId}/${lessonId}`
        );
        return response.data;
    } catch (error) {
        throw error.response?.data || {
            message: "Failed to fetch sessions by child and lesson",
        };
    }
};

// UPDATE SESSION
export const updateCompleteProblemSolvingSession = async (id, data) => {
    try {
        const response = await axios.put(`${API_BASE_URL}/${id}`, data);
        return response.data;
    } catch (error) {
        throw error.response?.data || { message: "Failed to update session" };
    }
};

// DELETE SESSION
export const deleteCompleteProblemSolvingSession = async (id) => {
    try {
        const response = await axios.delete(`${API_BASE_URL}/${id}`);
        return response.data;
    } catch (error) {
        throw error.response?.data || { message: "Failed to delete session" };
    }
};