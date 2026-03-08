import axios from "axios";

const API_BASE = "http://localhost:5000/chromabloom/stressAnalysis";

class StressAnalysisService {
  static async getHistory(caregiverId, limit = 14) {
    if (!caregiverId) {
      throw new Error("caregiverId is required");
    }

    const { data } = await axios.get(
      `${API_BASE}/history/${caregiverId}`,
      {
        params: { limit },
      }
    );

    return data;
  }
}

export default StressAnalysisService;