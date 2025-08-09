import React, { useEffect, useState } from "react";
import { apiService } from "../../services/api";
import { Book } from "../../types";
import { useAuth } from "../../contexts/AuthContext";
import { Search, Book as BookIcon, User, Hash, Copy, Plus } from "lucide-react";

const BookList: React.FC = () => {
  const { user } = useAuth();
  const [books, setBooks] = useState<Book[]>([]);
  const [filteredBooks, setFilteredBooks] = useState<Book[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [searchQuery, setSearchQuery] = useState("");
  const [borrowingId, setBorrowingId] = useState<number | null>(null);

  useEffect(() => {
    fetchBooks();
  }, []);

  useEffect(() => {
    if (searchQuery.trim()) {
      searchBooks(searchQuery);
    } else {
      setFilteredBooks(books);
    }
  }, [searchQuery, books]);

  const fetchBooks = async () => {
    try {
      const data = await apiService.getBooks();
      setBooks(data);
      setFilteredBooks(data);
    } catch (error: any) {
      setError(error.response?.data?.error || "Failed to fetch books");
    } finally {
      setLoading(false);
    }
  };

  const searchBooks = async (query: string) => {
    try {
      const data = await apiService.searchBooks(query);
      setFilteredBooks(data);
    } catch (error: any) {
      setError(error.response?.data?.error || "Search failed");
    }
  };

  const handleBorrowBook = async (bookId: number) => {
    setBorrowingId(bookId);
    try {
      await apiService.borrowBook(bookId);
      fetchBooks(); // Refresh the list to update available copies
      alert("Book borrowed successfully!");
    } catch (error: any) {
      const errorMessage = error.response?.data?.errors
        ? error.response.data.errors.join(", ")
        : error.response?.data?.error || "Failed to borrow book";
      alert(errorMessage);
    } finally {
      setBorrowingId(null);
    }
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
          <h1 className="text-3xl font-bold text-gray-900">Books</h1>
          <p className="mt-2 text-sm text-gray-700">
            Browse and search through our collection of books
          </p>
        </div>
      </div>

      {/* Search */}
      <div className="mt-6">
        <div className="max-w-lg">
          <div className="relative">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <Search className="h-5 w-5 text-gray-400" />
            </div>
            <input
              type="text"
              className="block w-full pl-10 pr-3 py-2 border border-gray-300 rounded-md leading-5 bg-white placeholder-gray-500 focus:outline-none focus:placeholder-gray-400 focus:ring-1 focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
              placeholder="Search by title, author, or genre..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
            />
          </div>
        </div>
      </div>

      {error && (
        <div className="mt-6 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
          {error}
        </div>
      )}

      {/* Books Grid */}
      <div className="mt-6 grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
        {filteredBooks.map((book) => (
          <div
            key={book.id}
            className="bg-white overflow-hidden shadow rounded-lg"
          >
            <div className="p-6">
              <div className="flex items-center justify-between mb-4">
                <div className="flex-shrink-0">
                  <BookIcon className="h-8 w-8 text-blue-600" />
                </div>
                <span
                  className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                    book.available_copies > 0
                      ? "bg-green-100 text-green-800"
                      : "bg-red-100 text-red-800"
                  }`}
                >
                  {book.available_copies > 0 ? "Available" : "Not Available"}
                </span>
              </div>

              <h3 className="text-lg font-medium text-gray-900 mb-2 line-clamp-2">
                {book.title}
              </h3>

              <div className="space-y-2 text-sm text-gray-600 mb-4">
                <div className="flex items-center">
                  <User className="h-4 w-4 mr-2" />
                  <span className="truncate">{book.author}</span>
                </div>
                <div className="flex items-center">
                  <Hash className="h-4 w-4 mr-2" />
                  <span>{book.genre}</span>
                </div>
                <div className="flex items-center">
                  <Copy className="h-4 w-4 mr-2" />
                  <span>
                    {book.available_copies} / {book.total_copies} available
                  </span>
                </div>
              </div>

              <div className="text-xs text-gray-500 mb-4">
                ISBN: {book.isbn}
              </div>

              {user?.role === "member" && (
                <button
                  onClick={() => handleBorrowBook(book.id)}
                  disabled={
                    book.available_copies === 0 || borrowingId === book.id
                  }
                  className={`w-full inline-flex items-center justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 ${
                    book.available_copies > 0
                      ? "text-white bg-blue-600 hover:bg-blue-700 focus:ring-blue-500"
                      : "text-gray-400 bg-gray-100 cursor-not-allowed"
                  }`}
                >
                  {borrowingId === book.id ? (
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                  ) : (
                    <Plus className="h-4 w-4 mr-2" />
                  )}
                  {borrowingId === book.id
                    ? "Borrowing..."
                    : book.available_copies > 0
                    ? "Borrow Book"
                    : "Not Available"}
                </button>
              )}
            </div>
          </div>
        ))}
      </div>

      {filteredBooks.length === 0 && !loading && (
        <div className="text-center py-12">
          <BookIcon className="mx-auto h-12 w-12 text-gray-400" />
          <h3 className="mt-2 text-sm font-medium text-gray-900">
            No books found
          </h3>
          <p className="mt-1 text-sm text-gray-500">
            {searchQuery
              ? "Try adjusting your search terms."
              : "No books are available in the library."}
          </p>
        </div>
      )}
    </div>
  );
};

export default BookList;
