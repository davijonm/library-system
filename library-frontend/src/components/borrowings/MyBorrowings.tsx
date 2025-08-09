import React, { useEffect, useState } from "react";
import { apiService } from "../../services/api";
import { Borrowing } from "../../types";
import { Book, Calendar, AlertTriangle } from "lucide-react";

const MyBorrowings: React.FC = () => {
  const [borrowings, setBorrowings] = useState<Borrowing[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    fetchBorrowings();
  }, []);

  const fetchBorrowings = async () => {
    try {
      const data = await apiService.getBorrowings();
      setBorrowings(data);
    } catch (error: any) {
      setError(error.response?.data?.error || "Failed to fetch borrowings");
    } finally {
      setLoading(false);
    }
  };

  const calculateDaysUntilDue = (dueDate: string) => {
    const due = new Date(dueDate);
    const today = new Date();
    const diffTime = due.getTime() - today.getTime();
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return diffDays;
  };

  const activeBorrowings = borrowings.filter((b) => !b.returned_at);

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  return (
    <div className="px-4 sm:px-0">
      <div className="sm:flex sm:items-center">
        <div className="sm:flex-auto">
          <h1 className="text-3xl font-bold text-gray-900">
            My Borrowed Books
          </h1>
          <p className="mt-2 text-sm text-gray-700">
            View your current book borrowings and due dates
          </p>
        </div>
      </div>

      {error && (
        <div className="mt-6 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
          {error}
        </div>
      )}

      {activeBorrowings.length === 0 && !loading ? (
        <div className="text-center py-12">
          <Book className="mx-auto h-12 w-12 text-gray-400" />
          <h3 className="mt-2 text-sm font-medium text-gray-900">
            No borrowed books
          </h3>
          <p className="mt-1 text-sm text-gray-500">
            You haven't borrowed any books yet. Browse our collection to get
            started.
          </p>
        </div>
      ) : (
        <div className="mt-8 grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {activeBorrowings.map((borrowing) => {
            const daysUntilDue = calculateDaysUntilDue(borrowing.due_date);
            const isOverdue = daysUntilDue < 0;
            const isDueSoon = daysUntilDue <= 3 && daysUntilDue >= 0;

            return (
              <div
                key={borrowing.id}
                className={`bg-white overflow-hidden shadow rounded-lg border-l-4 ${
                  isOverdue
                    ? "border-red-500"
                    : isDueSoon
                    ? "border-yellow-500"
                    : "border-green-500"
                }`}
              >
                <div className="p-6">
                  <div className="flex items-center justify-between mb-4">
                    <Book className="h-8 w-8 text-blue-600" />
                    <span
                      className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                        isOverdue
                          ? "bg-red-100 text-red-800"
                          : isDueSoon
                          ? "bg-yellow-100 text-yellow-800"
                          : "bg-green-100 text-green-800"
                      }`}
                    >
                      {isOverdue
                        ? "Overdue"
                        : isDueSoon
                        ? "Due Soon"
                        : "Active"}
                    </span>
                  </div>

                  <h3 className="text-lg font-medium text-gray-900 mb-2">
                    {borrowing.book?.title}
                  </h3>

                  <div className="space-y-2 text-sm text-gray-600 mb-4">
                    <p>by {borrowing.book?.author}</p>
                    <p className="text-xs text-gray-500">
                      Genre: {borrowing.book?.genre}
                    </p>
                  </div>

                  <div className="space-y-2 text-sm mb-4">
                    <div className="flex items-center text-gray-600">
                      <Calendar className="h-4 w-4 mr-2" />
                      <span>
                        Borrowed:{" "}
                        {new Date(borrowing.borrowed_at).toLocaleDateString()}
                      </span>
                    </div>
                    <div
                      className={`flex items-center ${
                        isOverdue
                          ? "text-red-600"
                          : isDueSoon
                          ? "text-yellow-600"
                          : "text-gray-600"
                      }`}
                    >
                      <Calendar className="h-4 w-4 mr-2" />
                      <span>
                        Due: {new Date(borrowing.due_date).toLocaleDateString()}
                        {isOverdue &&
                          ` (${Math.abs(daysUntilDue)} days overdue)`}
                        {isDueSoon &&
                          !isOverdue &&
                          ` (${daysUntilDue} days left)`}
                      </span>
                    </div>
                  </div>

                  <div className="bg-gray-50 rounded-md p-3 text-center">
                    <p className="text-sm text-gray-600">
                      📚 To return this book, please visit the library or
                      contact a librarian
                    </p>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* Statistics Summary */}
      {activeBorrowings.length > 0 && (
        <div className="mt-8 bg-gray-50 rounded-lg p-6">
          <h3 className="text-lg font-medium text-gray-900 mb-4">Summary</h3>
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
            <div className="text-center">
              <div className="text-2xl font-bold text-blue-600">
                {activeBorrowings.length}
              </div>
              <div className="text-sm text-gray-500">Total Borrowed</div>
            </div>
            <div className="text-center">
              <div className="text-2xl font-bold text-yellow-600">
                {
                  activeBorrowings.filter((b) => {
                    const days = calculateDaysUntilDue(b.due_date);
                    return days <= 3 && days >= 0;
                  }).length
                }
              </div>
              <div className="text-sm text-gray-500">Due Soon</div>
            </div>
            <div className="text-center">
              <div className="text-2xl font-bold text-red-600">
                {
                  activeBorrowings.filter(
                    (b) => calculateDaysUntilDue(b.due_date) < 0
                  ).length
                }
              </div>
              <div className="text-sm text-gray-500">Overdue</div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default MyBorrowings;
