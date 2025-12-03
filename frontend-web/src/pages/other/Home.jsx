import React from "react";
import { Link } from "react-router-dom";

export const Home = () => {
  return (
    <div className="flex flex-col items-center justify-center h-screen bg-gray-50">
      <h1 className="text-4xl font-bold mb-10 text-gray-800">
        Welcome
      </h1>

      <div className="flex gap-6">
        <Link to="/admin_login">
          <button className="px-6 py-3 bg-blue-600 text-white rounded-lg shadow-md hover:bg-blue-700 transition duration-300">
            Admin Login
          </button>
        </Link>

        <Link to="/therapists_login">
          <button className="px-6 py-3 bg-green-600 text-white rounded-lg shadow-md hover:bg-green-700 transition duration-300">
            Therapists Login
          </button>
        </Link>
      </div>
    </div>
  );
};
