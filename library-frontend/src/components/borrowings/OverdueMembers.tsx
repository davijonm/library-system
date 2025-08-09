import React, { useEffect, useState } from "react";
import { apiService } from "../../services/api";
import { Borrowing } from "../../types";
import { AlertTriangle, User, Book, Calendar, CheckCircle } from "lucide-react";

const OverdueMembers: React.FC = () => {
  const [overdueBorrowings, setOverdueBorrowings] = useState<Borrowing[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [returningId, setReturningId] = useState<number | null>(null);

  useEffect(() => {
    fetchOverdueMembers();
  }, []);

  const fetchOverdueMembers = async () => {
    try {
      const data = await apiService.getOverdueMembers();
      setOverdueBorrowings(data);
    } catch (error: any) {
      setError(
        error.response?.data?.error || "Failed to fetch overdue members"
      );
    } finally {
      setLoading(false);
    }
  };

  const handleReturnBook = async (borrowingId: number) => {
    setReturningId(borrowingId);
    try {
      await apiService.returnBook(borrowingId);
      fetchOverdueMembers(); // Refresh the list
    } catch (error: any) {
      alert(error.response?.data?.error || "Failed to return book");
    } finally {
      setReturningId(null);
    }
  };

  const calculateDaysOverdue = (dueDate: string) => {
    const due = new Date(dueDate);
    const today = new Date();
    const diffTime = today.getTime() - due.getTime();
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return diffDays;
  };

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
          <h1 className="text-3xl font-bold text-gray-900">Overdue Members</h1>
          <p className="mt-2 text-sm text-gray-700">
            Manage overdue book returns and contact members
          </p>
        </div>
      </div>

      {error && (
        <div className="mt-6 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
          {error}
        </div>
      )}

      {overdueBorrowings.length === 0 && !loading ? (
        <div className="text-center py-12">
          <CheckCircle className="mx-auto h-12 w-12 text-green-400" />
          <h3 className="mt-2 text-sm font-medium text-gray-900">
            No overdue books
          </h3>
          <p className="mt-1 text-sm text-gray-500">
            All books have been returned on time. Great job!
          </p>
        </div>
      ) : (
        <div className="mt-8 flex flex-col">
          <div className="-my-2 -mx-4 overflow-x-auto sm:-mx-6 lg:-mx-8">
            <div className="inline-block min-w-full py-2 align-middle md:px-6 lg:px-8">
              <div className="overflow-hidden shadow ring-1 ring-black ring-opacity-5 md:rounded-lg">
                <table className="min-w-full divide-y divide-gray-300">
                  <thead className="bg-gray-50">
                    <tr>
                      <th
                        scope="col"
                        className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wide"
                      >
                        Member
                      </th>
                      <th
                        scope="col"
                        className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wide"
                      >
                        Book
                      </th>
                      <th
                        scope="col"
                        className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wide"
                      >
                        Due Date
                      </th>
                      <th
                        scope="col"
                        className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wide"
                      >
                        Days Overdue
                      </th>
                      <th scope="col" className="relative px-6 py-3">
                        <span className="sr-only">Actions</span>
                      </th>
                    </tr>
                  </thead>
                  <tbody className="bg-white divide-y divide-gray-200">
                    {overdueBorrowings.map((borrowing) => {
                      const daysOverdue = calculateDaysOverdue(
                        borrowing.due_date
                      );
                      return (
                        <tr key={borrowing.id} className="hover:bg-gray-50">
                          <td className="px-6 py-4 whitespace-nowrap">
                            <div className="flex items-center">
                              <User className="h-6 w-6 text-gray-400 mr-3" />
                              <div>
                                <div className="text-sm font-medium text-gray-900">
                                  {borrowing.user?.email}
                                </div>
                                <div className="text-sm text-gray-500">
                                  Member
                                </div>
                              </div>
                            </div>
                          </td>
                          <td className="px-6 py-4">
                            <div className="flex items-center">
                              <Book className="h-5 w-5 text-gray-400 mr-2" />
                              <div>
                                <div className="text-sm font-medium text-gray-900">
                                  {borrowing.book?.title}
                                </div>
                                <div className="text-sm text-gray-500">
                                  by {borrowing.book?.author}
                                </div>
                              </div>
                            </div>
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap">
                            <div className="flex items-center text-red-600">
                              <Calendar className="h-4 w-4 mr-2" />
                              <div className="text-sm">
                                {new Date(
                                  borrowing.due_date
                                ).toLocaleDateString()}
                              </div>
                            </div>
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap">
                            <span
                              className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                                daysOverdue > 7
                                  ? "bg-red-100 text-red-800"
                                  : "bg-yellow-100 text-yellow-800"
                              }`}
                            >
                              <AlertTriangle className="h-3 w-3 mr-1" />
                              {daysOverdue} {daysOverdue === 1 ? "day" : "days"}
                            </span>
                          </td>
                          <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                            <button
                              onClick={() => handleReturnBook(borrowing.id)}
                              disabled={returningId === borrowing.id}
                              className="inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-white bg-green-600 hover:bg-green-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-green-500 disabled:opacity-50"
                            >
                              {returningId === borrowing.id ? (
                                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                              ) : (
                                <CheckCircle className="h-4 w-4 mr-2" />
                              )}
                              {returningId === borrowing.id
                                ? "Returning..."
                                : "Mark Returned"}
                            </button>
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Summary */}
      {overdueBorrowings.length > 0 && (
        <div className="mt-6 bg-yellow-50 border border-yellow-200 rounded-md p-4">
          <div className="flex">
            <div className="flex-shrink-0">
              <AlertTriangle className="h-5 w-5 text-yellow-400" />
            </div>
            <div className="ml-3">
              <h3 className="text-sm font-medium text-yellow-800">
                {overdueBorrowings.length} overdue book
                {overdueBorrowings.length !== 1 ? "s" : ""}
              </h3>
              <div className="mt-2 text-sm text-yellow-700">
                <p>
                  Consider contacting members with overdue books to arrange
                  returns. Books overdue for more than 7 days may require
                  additional follow-up.
                </p>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default OverdueMembers;
