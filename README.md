# Library Management System

A full-stack library management system with a Ruby on Rails API backend and a modern React TypeScript frontend, providing comprehensive book management and borrowing functionality.

## Features

### Core Functionality

- **User Management**: Registration, authentication, and role-based access control
- **Book Management**: CRUD operations for library inventory
- **Borrowing System**: Book checkout, return tracking, and due date management
- **Search & Discovery**: Advanced search by title, author, and genre
- **Dashboard Analytics**: Role-specific dashboards with key metrics
- **Overdue Management**: Automated tracking and management of overdue books

### User Roles

#### Librarian

- Manage book inventory (add, edit, delete books)
- Process book returns
- View overdue members and books
- Access comprehensive dashboard with library statistics
- All member capabilities

#### Member

- Browse and search book collection
- Borrow available books
- View personal borrowing history with detailed status
- Track due dates and overdue books
- Personal dashboard with borrowing status
- **Note**: Book returns are processed by librarians

## Architecture

This system consists of two main components:

### Backend (Rails API)

- **Port**: 3000
- **Technology**: Ruby on Rails 7 with PostgreSQL
- **Features**: JWT authentication, RESTful API, comprehensive testing

### Frontend (React App)

- **Port**: 3001
- **Technology**: React 18 with TypeScript, Tailwind CSS
- **Features**: Responsive design, role-based access, real-time search

## Prerequisites

- **Backend**: Docker and Docker Compose
- **Frontend**: Node.js 16+ and npm
- Git

## Quick Start

### Full Stack (API + Frontend)

**Single Command:**

```bash
# Clone the repository
git clone https://github.com/davijonm/library-system.git
cd library-system

# Start both backend and frontend together
chmod +x ./start-fullstack.sh
./start-fullstack.sh
```

The system will be available at:

- **Rails API**: http://localhost:3000
- **React Frontend**: http://localhost:3001
- **PostgreSQL**: localhost:5432

### Rails Application (`library_rails`)

- **Port**: 3000
- **Environment**: Development
- **Features**:
  - Hot reloading for development
  - Automatic database setup
  - Bundle caching

### PostgreSQL Database (`library_postgres`)

- **Port**: 5432
- **Database**: library_api_development
- **Features**:
  - Health checks
  - Persistent data storage
  - Optimized for development

## API Endpoints

### Authentication

```
POST /register     # Register a new user
POST /login        # Login user
{
  "email": "user@example.com",
  "password": "password123"
}
POST /logout       # Logout user
```

### Books

```
GET    /books              # List all books
GET    /books/:id          # Get specific book
POST   /books              # Create book (Librarian only)
{
  "book": {
    "title": "Book Title",
    "author": "Author Name",
    "genre": "Fiction",
    "isbn": "978-1234567890",
    "total_copies": 5,
    "available_copies": 5
  }
}
PUT    /books/:id          # Update book (Librarian only)
{
  "book": {
    "title": "Updated Title"
  }
}
DELETE /books/:id          # Delete book (Librarian only)
GET    /books/search       # Search books
```

### Borrowings

```
GET    /borrowings                    # List user borrowings
GET    /borrowings/:id                # Get specific borrowing
POST   /borrowings                    # Borrow a book
{
  "book_id": 1
}
PATCH  /borrowings/:id/return_book    # Return a book (Librarian only)
GET    /borrowings/dashboard          # User dashboard
GET    /borrowings/overdue_members    # Overdue members (Librarian only)
```

## User Roles

### Librarian

- Can create, update, and delete books
- Can mark books as returned
- Can view overdue members
- Full dashboard access

### Member

- Can view available books
- Can borrow books
- Can view their borrowing history
- Limited dashboard access

## Testing

The application includes comprhensive RSpec tests and are covered with simple-cov (96%)

```bash
# Prepare the test database
docker compose exec rails bash -c "RAILS_ENV=test rails db:reset"
```

```bash
# Run all tests
docker compose exec rails bash -c "RAILS_ENV=test bundle exec rspec ./spec"
```

## Authentication

The API uses JWT (JSON Web Tokens) for authentication:

1. **Register**: `POST /register` with email, password, and role
2. **Login**: `POST /login` with email and password
3. **Use Token**: Include `Authorization: Bearer <token>` in subsequent requests

### Sample Users (from seeds)

- **Librarian**: `librarian@library.com` / `password123`
- **Member 1**: `member1@library.com` / `password123`
- **Member 2**: `member2@library.com` / `password123`

## Frontend Features

### Modern React Interface

- **Responsive Design**: Mobile-first approach with Tailwind CSS
- **TypeScript**: Full type safety and better developer experience
- **Real-time Search**: Instant search results as you type
- **Loading States**: Smooth user experience with proper loading indicators
- **Error Handling**: Comprehensive error messages and fallback states

### User Experience

- **Role-based Navigation**: Different menu items based on user role
- **Dashboard Analytics**: Visual representation of key metrics
- **Form Validation**: Client-side validation with helpful error messages
- **Mobile Friendly**: Touch-friendly interface for mobile devices
- **Accessibility**: Semantic HTML and keyboard navigation support

### Technical Features

- **JWT Authentication**: Secure token-based authentication
- **API Integration**: Seamless communication with Rails backend
- **State Management**: React Context for global state
- **Route Protection**: Role-based route access control
- **Component Architecture**: Reusable and maintainable components

## Database Schema

### Users

- `id`: Primary key
- `email`: Unique email address
- `password_digest`: Hashed password
- `role`: 'librarian' or 'member'
- `created_at`, `updated_at`: Timestamps

### Books

- `id`: Primary key
- `title`: Book title
- `author`: Book author
- `genre`: Book genre
- `isbn`: Unique ISBN
- `total_copies`: Total number of copies
- `available_copies`: Available copies
- `created_at`, `updated_at`: Timestamps

### Borrowings

- `id`: Primary key
- `user_id`: Foreign key to users
- `book_id`: Foreign key to books
- `borrowed_at`: When book was borrowed
- `due_date`: When book is due
- `returned_at`: When book was returned (nullable)
- `created_at`, `updated_at`: Timestamps

### Reset Everything

```bash
# Stop and remove everything
docker compose down -v

# Remove all images
docker system prune -a

# Start fresh
./start.sh
```
