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

## 🏗️ Architecture

```
library-system/
├── library-api/          # Rails application
├── docker-compose.yml    # Multi-container setup
├── Dockerfile           # Rails container definition
├── start.sh             # Quick start script
└── README.md           # This file
```

## 🐳 Docker Services

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

## 📋 API Endpoints

### Authentication

```
POST /register     # Register a new user
POST /login        # Login user
POST /logout       # Logout user
```

### Books

```
GET    /books              # List all books
GET    /books/:id          # Get specific book
POST   /books              # Create book (Librarian only)
PUT    /books/:id          # Update book (Librarian only)
DELETE /books/:id          # Delete book (Librarian only)
GET    /books/search       # Search books
```

### Borrowings

```
GET    /borrowings                    # List user borrowings
GET    /borrowings/:id                # Get specific borrowing
POST   /borrowings                    # Borrow a book
PATCH  /borrowings/:id/return_book    # Return a book (Librarian only)
GET    /borrowings/dashboard          # User dashboard
GET    /borrowings/overdue_members    # Overdue members (Librarian only)
```

## 🔧 Development Commands

### Start the system

```bash
docker compose up -d
```

### View logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f rails
docker compose logs -f postgres
```

### Stop the system

```bash
docker compose down
```

### Rebuild containers

```bash
docker compose up --build -d
```

### Access Rails console

```bash
docker compose exec rails rails console
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

## 👥 User Roles

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

## 🧪 Testing

The application includes comprehensive RSpec tests:

```bash
# Run all tests
docker-compose exec rails bundle exec rspec

# Run specific test files
docker-compose exec rails bundle exec rspec spec/models/
docker-compose exec rails bundle exec rspec spec/requests/

# Run with coverage
docker-compose exec rails bundle exec rspec --format documentation
```

## 🔐 Authentication

The API uses JWT (JSON Web Tokens) for authentication:

1. **Register**: `POST /register` with email, password, and role
2. **Login**: `POST /login` with email and password
3. **Use Token**: Include `Authorization: Bearer <token>` in subsequent requests

### Sample Users (from seeds)

- **Librarian**: `librarian@library.com` / `password123`
- **Member 1**: `member1@library.com` / `password123`
- **Member 2**: `member2@library.com` / `password123`

## 📊 Database Schema

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

## 🛠️ Environment Variables

Key environment variables for the Rails container:

```bash
RAILS_ENV=development
DATABASE_HOST=postgres
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=password
RAILS_MASTER_KEY=your_master_key_here
```

## 🐛 Troubleshooting

### Common Issues

1. **Port already in use**

   ```bash
   # Check what's using the port
   lsof -i :3000
   # Stop the conflicting service
   ```

2. **Database connection issues**

   ```bash
   # Restart the database
   docker-compose restart postgres
   ```

3. **Rails server not starting**

   ```bash
   # Check logs
   docker-compose logs rails
   # Rebuild the container
   docker-compose up --build rails
   ```

4. **Permission issues**
   ```bash
   # Fix file permissions
   sudo chown -R $USER:$USER .
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

## 📝 License

This project is licensed under the MIT License.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

---

**Happy coding! 📚✨**
