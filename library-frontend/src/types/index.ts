export interface User {
  id: number;
  email: string;
  role: "librarian" | "member";
}

export interface Book {
  id: number;
  title: string;
  author: string;
  genre: string;
  isbn: string;
  total_copies: number;
  available_copies: number;
  created_at: string;
  updated_at: string;
}

export interface Borrowing {
  id: number;
  user_id: number;
  book_id: number;
  borrowed_at: string;
  due_date: string;
  returned_at: string | null;
  book?: Book;
  user?: User;
}

export interface AuthResponse {
  user: User;
  token: string;
}

export interface DashboardData {
  // Librarian dashboard
  total_books?: number;
  total_borrowed?: number;
  books_due_today?: number;
  overdue_books?: Borrowing[];

  // Member dashboard
  my_borrowings?: Borrowing[];
}

export interface ApiError {
  error?: string;
  errors?: string[];
}
