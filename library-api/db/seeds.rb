# sample users
librarian = User.create!(
  email: 'librarian@library.com',
  password: 'password123',
  role: 'librarian'
)

member1 = User.create!(
  email: 'member1@library.com',
  password: 'password123',
  role: 'member'
)

member2 = User.create!(
  email: 'member2@library.com',
  password: 'password123',
  role: 'member'
)

# sample books
books = [
  {
    title: 'The Great Gatsby',
    author: 'F. Scott Fitzgerald',
    genre: 'Fiction',
    isbn: '978-0743273565',
    total_copies: 5,
    available_copies: 5
  },
  {
    title: 'To Kill a Mockingbird',
    author: 'Harper Lee',
    genre: 'Fiction',
    isbn: '978-0446310789',
    total_copies: 3,
    available_copies: 3
  },
  {
    title: '1984',
    author: 'George Orwell',
    genre: 'Science Fiction',
    isbn: '978-0451524935',
    total_copies: 4,
    available_copies: 4
  },
  {
    title: 'Pride and Prejudice',
    author: 'Jane Austen',
    genre: 'Romance',
    isbn: '978-0141439518',
    total_copies: 2,
    available_copies: 2
  },
  {
    title: 'The Hobbit',
    author: 'J.R.R. Tolkien',
    genre: 'Fantasy',
    isbn: '978-0547928241',
    total_copies: 6,
    available_copies: 6
  },
  {
    title: 'The Catcher in the Rye',
    author: 'J.D. Salinger',
    genre: 'Fiction',
    isbn: '978-0316769488',
    total_copies: 3,
    available_copies: 3
  },
  {
    title: 'Lord of the Flies',
    author: 'William Golding',
    genre: 'Fiction',
    isbn: '978-0399501487',
    total_copies: 4,
    available_copies: 4
  },
  {
    title: 'Animal Farm',
    author: 'George Orwell',
    genre: 'Fiction',
    isbn: '978-0451526342',
    total_copies: 3,
    available_copies: 3
  }
]

books.each do |book_attrs|
  Book.create!(book_attrs)
end

# some sample borrowings
book1 = Book.first
book2 = Book.second
book3 = Book.last

# member1 borrows a book
Borrowing.create!(
  user: member1,
  book: book1,
  borrowed_at: 1.week.ago,
  due_date: 1.week.from_now
)

# member1 borrows a book and doenst return it
Borrowing.create!(
  user: member1,
  book: book3,
  borrowed_at: 2.weeks.ago,
  due_date: 1.day.ago  # This will be overdue
)

# member2 borrows a book
Borrowing.create!(
  user: member2,
  book: book2,
  borrowed_at: 1.week.ago,
  due_date: 1.week.from_now
)

puts "Seed data created successfully!"
puts "Librarian: librarian@library.com / password123"
puts "Member 1: member1@library.com / password123"
puts "Member 2: member2@library.com / password123"
