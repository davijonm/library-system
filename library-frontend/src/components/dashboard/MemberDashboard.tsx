import React from "react";
import { DashboardData } from "../../types";
import { Book, Calendar, AlertTriangle, Search } from "lucide-react";
import { Link } from "react-router-dom";

interface MemberDashboardProps {
  data: DashboardData;
}

const MemberDashboard: React.FC<MemberDashboardProps> = ({ data }) => {
  const activeBorrowings = data.my_borrowings || [];
  const overdueBorrowings = activeBorrowings.filter((borrowing) => {
    const dueDate = new Date(borrowing.due_date);
    const today = new Date();
    return dueDate < today && !borrowing.returned_at;
  });

  return (
    <div className="space-y-6">
      {/* Stats */}
      <div className="grid grid-cols-1 gap-5 sm:grid-cols-3">
        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <div className="inline-flex items-center justify-center p-3 rounded-md bg-blue-500">
                  <Book className="h-6 w-6 text-white" />
                </div>
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">
                    Books Borrowed
                  </dt>
                  <dd className="text-lg font-medium text-gray-900">
                    {activeBorrowings.length}
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <div className="inline-flex items-center justify-center p-3 rounded-md bg-yellow-500">
                  <Calendar className="h-6 w-6 text-white" />
                </div>
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">
                    Due Soon
                  </dt>
                  <dd className="text-lg font-medium text-gray-900">
                    {
                      activeBorrowings.filter((b) => {
                        const dueDate = new Date(b.due_date);
                        const today = new Date();
                        const diffTime = dueDate.getTime() - today.getTime();
                        const diffDays = Math.ceil(
                          diffTime / (1000 * 60 * 60 * 24)
                        );
                        return diffDays <= 3 && diffDays >= 0;
                      }).length
                    }
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <div className="inline-flex items-center justify-center p-3 rounded-md bg-red-500">
                  <AlertTriangle className="h-6 w-6 text-white" />
                </div>
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">
                    Overdue Books
                  </dt>
                  <dd className="text-lg font-medium text-gray-900">
                    {overdueBorrowings.length}
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="bg-white shadow rounded-lg">
        <div className="px-6 py-4 border-b border-gray-200">
          <h3 className="text-lg leading-6 font-medium text-gray-900">
            Quick Actions
          </h3>
        </div>
        <div className="px-6 py-4">
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
            <Link
              to="/books"
              className="inline-flex items-center justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              <Search className="h-4 w-4 mr-2" />
              Browse Books
            </Link>
            <Link
              to="/my-borrowings"
              className="inline-flex items-center justify-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              <Book className="h-4 w-4 mr-2" />
              My Books
            </Link>
            <Link
              to="/books"
              className="inline-flex items-center justify-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              <Search className="h-4 w-4 mr-2" />
              Search Books
            </Link>
          </div>
        </div>
      </div>

      {/* My Borrowed Books */}
      {activeBorrowings.length > 0 && (
        <div className="bg-white shadow rounded-lg">
          <div className="px-6 py-4 border-b border-gray-200">
            <h3 className="text-lg leading-6 font-medium text-gray-900">
              My Borrowed Books
            </h3>
          </div>
          <div className="px-6 py-4">
            <div className="space-y-4">
              {activeBorrowings.map((borrowing) => {
                const dueDate = new Date(borrowing.due_date);
                const today = new Date();
                const diffTime = dueDate.getTime() - today.getTime();
                const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
                const isOverdue = diffDays < 0;
                const isDueSoon = diffDays <= 3 && diffDays >= 0;

                return (
                  <div
                    key={borrowing.id}
                    className={`flex items-center justify-between p-4 rounded-lg ${
                      isOverdue
                        ? "bg-red-50"
                        : isDueSoon
                        ? "bg-yellow-50"
                        : "bg-gray-50"
                    }`}
                  >
                    <div>
                      <p className="text-sm font-medium text-gray-900">
                        {borrowing.book?.title}
                      </p>
                      <p className="text-sm text-gray-500">
                        by {borrowing.book?.author}
                      </p>
                      <p
                        className={`text-sm ${
                          isOverdue
                            ? "text-red-600"
                            : isDueSoon
                            ? "text-yellow-600"
                            : "text-gray-500"
                        }`}
                      >
                        Due: {dueDate.toLocaleDateString()}
                        {isOverdue && " (Overdue)"}
                        {isDueSoon && !isOverdue && " (Due Soon)"}
                      </p>
                    </div>
                    <div className="text-right">
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
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      )}

      {/* No books message */}
      {activeBorrowings.length === 0 && (
        <div className="bg-white shadow rounded-lg">
          <div className="px-6 py-8 text-center">
            <Book className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">
              No borrowed books
            </h3>
            <p className="mt-1 text-sm text-gray-500">
              Start by browsing our collection and borrowing some books.
            </p>
            <div className="mt-6">
              <Link
                to="/books"
                className="inline-flex items-center px-4 py-2 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
              >
                <Search className="h-4 w-4 mr-2" />
                Browse Books
              </Link>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default MemberDashboard;
