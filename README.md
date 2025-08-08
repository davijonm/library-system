# Library Management System API

A Ruby on Rails API for managing a library system with user authentication, book management, and borrowing functionality.

## Features

### Authentication & Authorization

- User registration and login with JWT tokens
- Two user roles: Librarian and Member
- Role-based access control for different operations

### Book Management

- CRUD operations for books (Librarians only)
- Book search by title, author, or genre
- Track total copies and available copies
- ISBN validation and uniqueness

### Borrowing System

- Members can borrow available books
- Automatic due date calculation (2 weeks from borrowing)
- Prevent duplicate borrowings of the same book
- Librarians can mark books as returned
- Track overdue books and due dates

### Dashboard

- **Librarian Dashboard**: Total books, borrowed books, books due today, overdue books
- **Member Dashboard**: User's borrowed books, due dates, overdue books

## Technology Stack

- **Ruby**: 3.4.2
- **Rails**: 8.0.2 (API mode)
- **Database**: PostgreSQL
- **Authentication**: JWT (JSON Web Tokens)
- **Testing**: RSpec, FactoryBot, Shoulda Matchers
- **Containerization**: Docker Compose

## Prerequisites

- Ruby 3.4.2
- Docker and Docker Compose
- PostgreSQL (via Docker)

## Setup Instructions

### 1. Clone and Navigate

```bash
cd library-api
```

### 2. Start PostgreSQL with Docker

```bash
docker compose up -d
```

### 3. Install Dependencies

```bash
bundle install
```

### 4. Setup Database

```bash
rails db:create db:migrate db:seed
```

### 5. Start the Server

```bash
rails server
```

The API will be available at `http://localhost:3000`

## API Endpoints

### Authentication

#### Register User

```
POST /register
Content-Type: application/json

{
  "user": {
    "email": "user@example.com",
    "password": "password123",
    "role": "member"
  }
}
```

#### Login

```
POST /login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

#### Logout

```
POST /logout
Authorization: Bearer <token>
```

### Books

#### List Books

```
GET /books
Authorization: Bearer <token>
```

#### Search Books

```
GET /books?search=query
Authorization: Bearer <token>
```

#### Get Book

```
GET /books/:id
Authorization: Bearer <token>
```

#### Create Book (Librarian only)

```
POST /books
Authorization: Bearer <token>
Content-Type: application/json

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
```

#### Update Book (Librarian only)

```
PUT /books/:id
Authorization: Bearer <token>
Content-Type: application/json

{
  "book": {
    "title": "Updated Title"
  }
}
```

#### Delete Book (Librarian only)

```
DELETE /books/:id
Authorization: Bearer <token>
```

### Borrowings

#### List User Borrowings

```
GET /borrowings
Authorization: Bearer <token>
```

#### Get Borrowing

```
GET /borrowings/:id
Authorization: Bearer <token>
```

#### Borrow Book

```
POST /borrowings
Authorization: Bearer <token>
Content-Type: application/json

{
  "book_id": 1
}
```

#### Return Book (Librarian only)

```
PATCH /borrowings/:id/return_book
Authorization: Bearer <token>
```

#### Dashboard

```
GET /borrowings/dashboard
Authorization: Bearer <token>
```

#### Overdue Members (Librarian only)

```
GET /borrowings/overdue_members
Authorization: Bearer <token>
```

## Sample Data

The application comes with seeded data for testing:

### Users

- **Librarian**: `librarian@library.com` / `password123`
- **Member 1**: `member1@library.com` / `password123`
- **Member 2**: `member2@library.com` / `password123`

### Books

- The Great Gatsby
- To Kill a Mockingbird
- 1984
- Pride and Prejudice
- The Hobbit
- The Catcher in the Rye
- Lord of the Flies
- Animal Farm

## Testing

### Run All Tests

```bash
bundle exec rspec
```

### Run Specific Test Files

```bash
bundle exec rspec spec/models/
bundle exec rspec spec/requests/
```

### Test Coverage

The test suite includes:

- Model validations and associations
- Controller actions and authorization
- API endpoint functionality
- Business logic for borrowing and returning

## Database Schema

### Users

- `id`: Primary key
- `email`: Unique email address
- `password_digest`: Encrypted password
- `role`: User role (librarian/member)
- `created_at`, `updated_at`: Timestamps

### Books

- `id`: Primary key
- `title`: Book title
- `author`: Book author
- `genre`: Book genre
- `isbn`: Unique ISBN
- `total_copies`: Total number of copies
- `available_copies`: Number of available copies
- `created_at`, `updated_at`: Timestamps

### Borrowings

- `id`: Primary key
- `user_id`: Foreign key to users
- `book_id`: Foreign key to books
- `borrowed_at`: When the book was borrowed
- `due_date`: When the book is due
- `returned_at`: When the book was returned (nullable)
- `created_at`, `updated_at`: Timestamps

## Environment Variables

The application uses the following environment variables for database configuration:

- `DATABASE_HOST`: Database host (default: localhost)
- `DATABASE_USERNAME`: Database username (default: postgres)
- `DATABASE_PASSWORD`: Database password (default: password)

## Development

### Adding New Features

1. Create models with `rails generate model`
2. Add validations and associations
3. Create controllers with `rails generate controller`
4. Add routes to `config/routes.rb`
5. Write tests for models and controllers
6. Update documentation

### Code Style

The project uses RuboCop for code style enforcement:

```bash
bundle exec rubocop
```

