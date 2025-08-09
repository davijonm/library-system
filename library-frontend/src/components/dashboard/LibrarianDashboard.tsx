import React from "react";
import { DashboardData } from "../../types";
import { Book, Users, Calendar, AlertTriangle } from "lucide-react";
import { Link } from "react-router-dom";

interface LibrarianDashboardProps {
  data: DashboardData;
}

const LibrarianDashboard: React.FC<LibrarianDashboardProps> = ({ data }) => {
  const stats = [
    {
      name: "Total Books",
      value: data.total_books || 0,
      icon: Book,
      color: "bg-blue-500",
    },
    {
      name: "Books Borrowed",
      value: data.total_borrowed || 0,
      icon: Users,
      color: "bg-green-500",
    },
    {
      name: "Due Today",
      value: data.books_due_today || 0,
      icon: Calendar,
      color: "bg-yellow-500",
    },
    {
      name: "Overdue Books",
      value: data.overdue_books?.length || 0,
      icon: AlertTriangle,
      color: "bg-red-500",
    },
  ];

  return (
    <div className="space-y-6">
      {/* Stats Grid */}
      <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        {stats.map((stat) => {
          const Icon = stat.icon;
          return (
            <div
              key={stat.name}
              className="bg-white overflow-hidden shadow rounded-lg"
            >
              <div className="p-5">
                <div className="flex items-center">
                  <div className="flex-shrink-0">
                    <div
                      className={`inline-flex items-center justify-center p-3 rounded-md ${stat.color}`}
                    >
                      <Icon className="h-6 w-6 text-white" />
                    </div>
                  </div>
                  <div className="ml-5 w-0 flex-1">
                    <dl>
                      <dt className="text-sm font-medium text-gray-500 truncate">
                        {stat.name}
                      </dt>
                      <dd className="text-lg font-medium text-gray-900">
                        {stat.value}
                      </dd>
                    </dl>
                  </div>
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {/* Quick Actions */}
      <div className="bg-white shadow rounded-lg">
        <div className="px-6 py-4 border-b border-gray-200">
          <h3 className="text-lg leading-6 font-medium text-gray-900">
            Quick Actions
          </h3>
        </div>
        <div className="px-6 py-4">
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
            <Link
              to="/manage-books"
              className="inline-flex items-center justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              <Book className="h-4 w-4 mr-2" />
              Manage Books
            </Link>
            <Link
              to="/overdue-members"
              className="inline-flex items-center justify-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              <AlertTriangle className="h-4 w-4 mr-2" />
              View Overdue Members
            </Link>
            <Link
              to="/books"
              className="inline-flex items-center justify-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
            >
              <Book className="h-4 w-4 mr-2" />
              Browse Books
            </Link>
          </div>
        </div>
      </div>

      {/* Overdue Books */}
      {data.overdue_books && data.overdue_books.length > 0 && (
        <div className="bg-white shadow rounded-lg">
          <div className="px-6 py-4 border-b border-gray-200">
            <h3 className="text-lg leading-6 font-medium text-gray-900">
              Recent Overdue Books
            </h3>
          </div>
          <div className="px-6 py-4">
            <div className="space-y-4">
              {data.overdue_books.slice(0, 5).map((borrowing) => (
                <div
                  key={borrowing.id}
                  className="flex items-center justify-between p-4 bg-red-50 rounded-lg"
                >
                  <div>
                    <p className="text-sm font-medium text-gray-900">
                      {borrowing.book?.title}
                    </p>
                    <p className="text-sm text-gray-500">
                      Borrowed by: {borrowing.user?.email}
                    </p>
                    <p className="text-sm text-red-600">
                      Due: {new Date(borrowing.due_date).toLocaleDateString()}
                    </p>
                  </div>
                  <div className="text-right">
                    <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
                      Overdue
                    </span>
                  </div>
                </div>
              ))}
              {data.overdue_books.length > 5 && (
                <div className="text-center">
                  <Link
                    to="/overdue-members"
                    className="text-blue-600 hover:text-blue-500 text-sm font-medium"
                  >
                    View all {data.overdue_books.length} overdue books
                  </Link>
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default LibrarianDashboard;
