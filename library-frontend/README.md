# Library Management System - Frontend

A modern React TypeScript frontend for the Library Management System, providing a responsive and user-friendly interface for both librarians and members.

## Features

### Authentication & Authorization

- User registration and login
- JWT token-based authentication
- Role-based access control (Librarian/Member)
- Secure logout functionality

### Member Features

- Browse and search books by title, author, or genre
- Borrow available books
- View personal borrowing history with detailed status
- Track due dates and overdue books
- Member-specific dashboard with quick actions
- **Note**: Book returns must be processed by librarians

### Librarian Features

- All member features plus:
- Add, edit, and delete books
- Mark books as returned
- View overdue members
- Comprehensive dashboard with statistics
- Manage library inventory

### User Experience

- Responsive design for mobile, tablet, and desktop
- Modern UI with Tailwind CSS
- Loading states and error handling
- Real-time search functionality
- Intuitive navigation and layout

## Technology Stack

- **React 18** with TypeScript
- **React Router** for navigation
- **Tailwind CSS** for styling
- **Axios** for API communication
- **Lucide React** for icons
- **Context API** for state management

## Getting Started

### Prerequisites

- Node.js 16+ and npm
- Running Rails API backend on `http://localhost:3000`

### Installation

1. Navigate to the frontend directory:

   ```bash
   cd library-frontend
   ```

2. Install dependencies:

   ```bash
   npm install
   ```

3. Start the development server:
   ```bash
   npm start
   ```

The application will be available at `http://localhost:3001`

### Demo Accounts

Use these accounts to test the application:

- **Librarian**: `librarian@library.com` / `password123`
- **Member**: `member1@library.com` / `password123`

## Project Structure

```
src/
├── components/          # Reusable UI components
│   ├── auth/           # Authentication components
│   ├── books/          # Book-related components
│   ├── borrowings/     # Borrowing management
│   ├── dashboard/      # Dashboard components
│   └── layout/         # Layout and navigation
├── contexts/           # React contexts
├── services/           # API service layer
├── types/              # TypeScript type definitions
├── App.tsx             # Main application component
└── index.tsx           # Application entry point
```

## API Integration

The frontend communicates with the Rails API backend through:

- **Authentication**: Login, register, logout
- **Books**: CRUD operations, search functionality
- **Borrowings**: Borrow books, return books, dashboard data

### API Endpoints Used

- `POST /register` - User registration
- `POST /login` - User authentication
- `POST /logout` - User logout
- `GET /books` - List all books
- `GET /books/search` - Search books
- `POST /books` - Create book (Librarian)
- `PUT /books/:id` - Update book (Librarian)
- `DELETE /books/:id` - Delete book (Librarian)
- `POST /borrowings` - Borrow book
- `PATCH /borrowings/:id/return_book` - Return book (Librarian)
- `GET /borrowings/dashboard` - Dashboard data
- `GET /borrowings/overdue_members` - Overdue members (Librarian)

## Key Features Implementation

### Authentication Flow

- JWT tokens stored in localStorage
- Automatic token inclusion in API requests
- Route protection based on authentication status
- Role-based component rendering

### Responsive Design

- Mobile-first approach with Tailwind CSS
- Responsive grid layouts for book displays
- Collapsible navigation for mobile devices
- Touch-friendly interface elements

### Error Handling

- Comprehensive error messages
- Loading states for async operations
- Form validation and feedback
- Graceful handling of API failures

### Search Functionality

- Real-time search as user types
- Search by title, author, or genre
- Debounced API calls for performance
- Clear search results display

## Available Scripts

- `npm start` - Start development server
- `npm build` - Build for production
- `npm test` - Run test suite
- `npm run eject` - Eject from Create React App

## Building for Production

```bash
npm run build
```

This creates a `build` folder with optimized production files.

