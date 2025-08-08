# Library Management System

A comprehensive Ruby on Rails API for managing a library system with authentication, book management, and borrowing functionality.

## Features

### Prerequisites

- Docker and Docker Compose installed
- Git

### One-Command Setup

```bash
# Clone the repository
git clone <repository-url>
cd library-system

# Start the entire system
./start.sh
```

The system will be available at:

- **Rails API**: http://localhost:3000
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

### Run tests

```bash
docker compose exec rails bundle exec rspec
```

### Database operations

```bash
# Reset database
docker compose exec rails rails db:reset

# Run migrations
docker compose exec rails rails db:migrate

# Seed data
docker compose exec rails rails db:seed
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

The application includes comprhensive RSpec tests:
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

## Environment Variables

Key environment variables for the Rails container:

```bash
RAILS_ENV=development
DATABASE_HOST=postgres
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=password
RAILS_MASTER_KEY=your_master_key_here
```

### Reset Everything

```bash
# Stop and remove everything
docker compose down -v

# Remove all images
docker system prune -a

# Start fresh
./start.sh
```
