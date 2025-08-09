import React from "react";
import {
  BrowserRouter as Router,
  Routes,
  Route,
  Navigate,
} from "react-router-dom";
import { AuthProvider } from "./contexts/AuthContext";
import ProtectedRoute from "./components/auth/ProtectedRoute";
import Layout from "./components/layout/Layout";
import Login from "./components/auth/Login";
import Register from "./components/auth/Register";
import Dashboard from "./components/dashboard/Dashboard";
import BookList from "./components/books/BookList";
import ManageBooks from "./components/books/ManageBooks";
import OverdueMembers from "./components/borrowings/OverdueMembers";
import MyBorrowings from "./components/borrowings/MyBorrowings";

function App() {
  return (
    <AuthProvider>
      <Router>
        <Routes>
          {/* Public routes */}
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />

          {/* Protected routes */}
          <Route
            path="/dashboard"
            element={
              <ProtectedRoute>
                <Layout>
                  <Dashboard />
                </Layout>
              </ProtectedRoute>
            }
          />

          <Route
            path="/books"
            element={
              <ProtectedRoute>
                <Layout>
                  <BookList />
                </Layout>
              </ProtectedRoute>
            }
          />

          {/* Member routes */}
          <Route
            path="/my-borrowings"
            element={
              <ProtectedRoute requiredRole="member">
                <Layout>
                  <MyBorrowings />
                </Layout>
              </ProtectedRoute>
            }
          />

          {/* Librarian only routes */}
          <Route
            path="/manage-books"
            element={
              <ProtectedRoute requiredRole="librarian">
                <Layout>
                  <ManageBooks />
                </Layout>
              </ProtectedRoute>
            }
          />

          <Route
            path="/overdue-members"
            element={
              <ProtectedRoute requiredRole="librarian">
                <Layout>
                  <OverdueMembers />
                </Layout>
              </ProtectedRoute>
            }
          />

          {/* Default redirect */}
          <Route path="/" element={<Navigate to="/dashboard" replace />} />
        </Routes>
      </Router>
    </AuthProvider>
  );
}

export default App;
