import axios, { AxiosInstance, AxiosResponse } from "axios";
import { User, Book, Borrowing, AuthResponse, DashboardData } from "../types";

const BASE_URL = "http://localhost:3000";

class ApiService {
  private api: AxiosInstance;

  constructor() {
    this.api = axios.create({
      baseURL: BASE_URL,
      headers: {
        "Content-Type": "application/json",
      },
    });

    // Request interceptor to add auth token
    this.api.interceptors.request.use((config) => {
      const token = localStorage.getItem("token");
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
      return config;
    });

    // Response interceptor to handle auth errors
    this.api.interceptors.response.use(
      (response) => response,
      (error) => {
        if (error.response?.status === 401) {
          localStorage.removeItem("token");
          localStorage.removeItem("user");
          window.location.href = "/login";
        }
        return Promise.reject(error);
      }
    );
  }

  // Authentication
  async register(
    email: string,
    password: string,
    role: "librarian" | "member"
  ): Promise<AuthResponse> {
    const response: AxiosResponse<AuthResponse> = await this.api.post(
      "/register",
      {
        user: { email, password, role },
      }
    );
    return response.data;
  }

  async login(email: string, password: string): Promise<AuthResponse> {
    const response: AxiosResponse<AuthResponse> = await this.api.post(
      "/login",
      {
        email,
        password,
      }
    );
    return response.data;
  }

  async logout(): Promise<void> {
    await this.api.post("/logout");
    localStorage.removeItem("token");
    localStorage.removeItem("user");
  }

  // Books
  async getBooks(): Promise<Book[]> {
    const response: AxiosResponse<Book[]> = await this.api.get("/books");
    return response.data;
  }

  async getBook(id: number): Promise<Book> {
    const response: AxiosResponse<Book> = await this.api.get(`/books/${id}`);
    return response.data;
  }

  async createBook(
    bookData: Omit<Book, "id" | "created_at" | "updated_at">
  ): Promise<Book> {
    const response: AxiosResponse<Book> = await this.api.post("/books", {
      book: bookData,
    });
    return response.data;
  }

  async updateBook(
    id: number,
    bookData: Partial<Omit<Book, "id" | "created_at" | "updated_at">>
  ): Promise<Book> {
    const response: AxiosResponse<Book> = await this.api.put(`/books/${id}`, {
      book: bookData,
    });
    return response.data;
  }

  async deleteBook(id: number): Promise<void> {
    await this.api.delete(`/books/${id}`);
  }

  async searchBooks(query: string): Promise<Book[]> {
    const response: AxiosResponse<Book[]> = await this.api.get(
      "/books/search",
      {
        params: { query },
      }
    );
    return response.data;
  }

  // Borrowings
  async getBorrowings(): Promise<Borrowing[]> {
    const response: AxiosResponse<Borrowing[]> = await this.api.get(
      "/borrowings"
    );
    return response.data;
  }

  async borrowBook(bookId: number): Promise<Borrowing> {
    const response: AxiosResponse<Borrowing> = await this.api.post(
      "/borrowings",
      {
        book_id: bookId,
      }
    );
    return response.data;
  }

  async returnBook(borrowingId: number): Promise<{ message: string }> {
    const response: AxiosResponse<{ message: string }> = await this.api.patch(
      `/borrowings/${borrowingId}/return_book`
    );
    return response.data;
  }

  async getDashboard(): Promise<DashboardData> {
    const response: AxiosResponse<DashboardData> = await this.api.get(
      "/borrowings/dashboard"
    );
    return response.data;
  }

  async getOverdueMembers(): Promise<Borrowing[]> {
    const response: AxiosResponse<Borrowing[]> = await this.api.get(
      "/borrowings/overdue_members"
    );
    return response.data;
  }
}

export const apiService = new ApiService();
