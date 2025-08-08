### Authentication & Authorization:
- JWT-based authentication
- User registration and login
- Role-based access control (Librarian/Member)

### Database Models:
- User model with authentication
- Book model with search functionality
- Borrowing model with business logic

### API Endpoints:
- Authentication routes (/register, /login, /logout)
- Books CRUD operations (/books)
- Borrowing operations (/borrowings)
- Dashboard functionality
- Search functionality

### Business Logic:
- Book borrowing with availability checks
- Due date calculation (2 weeks)
- Overdue book tracking
- Book return functionality
- Duplicate borrowing prevention

### Testing:
- Comprehensive RSpec test suite
- Model validations and associations
- Controller actions and authorization
- FactoryBot factories for test data

### Infrastructure:
- Docker Compose for PostgreSQL
- CORS configuration
- Seed data for testing