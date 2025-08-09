import React, { useEffect, useState } from "react";
import { useAuth } from "../../contexts/AuthContext";
import { apiService } from "../../services/api";
import { DashboardData } from "../../types";
import LibrarianDashboard from "./LibrarianDashboard";
import MemberDashboard from "./MemberDashboard";

const Dashboard: React.FC = () => {
  const { user } = useAuth();
  const [dashboardData, setDashboardData] = useState<DashboardData | null>(
    null
  );
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  // Refresh dashboard data without toggling the main loading spinner
  const refreshDashboard = async () => {
    try {
      const data = await apiService.getDashboard();
      setDashboardData(data);
    } catch (error: any) {
      setError(error.response?.data?.error || "Failed to fetch dashboard data");
    }
  };

  useEffect(() => {
    const initialLoad = async () => {
      try {
        const data = await apiService.getDashboard();
        setDashboardData(data);
      } catch (error: any) {
        setError(
          error.response?.data?.error || "Failed to fetch dashboard data"
        );
      } finally {
        setLoading(false);
      }
    };

    initialLoad();
  }, []);

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
        {error}
      </div>
    );
  }

  if (!dashboardData) {
    return (
      <div className="text-center text-gray-500">
        No dashboard data available
      </div>
    );
  }

  return (
    <div className="px-4 sm:px-0">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900">
          Welcome back, {user?.email}!
        </h1>
        <p className="mt-1 text-sm text-gray-600">
          {user?.role === "librarian"
            ? "Manage your library and monitor borrowings"
            : "Track your borrowed books and discover new ones"}
        </p>
      </div>

      {user?.role === "librarian" ? (
        <LibrarianDashboard data={dashboardData} onRefresh={refreshDashboard} />
      ) : (
        <MemberDashboard data={dashboardData} />
      )}
    </div>
  );
};

export default Dashboard;
