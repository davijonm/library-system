class BorrowingsController < ApplicationController
  before_action :set_borrowing, only: [:show, :return_book]
  before_action :authorize_librarian, only: [:return_book, :overdue_members]

  def index
    @borrowings = current_user.borrowings.includes(:book)
    render json: @borrowings
  end

  def show
    render json: @borrowing
  end

  def create
    @book = Book.find(params[:book_id])
    @borrowing = current_user.borrowings.build(book: @book)

    if @borrowing.save
      @book.borrow!
      render json: @borrowing, status: :created
    else
      render json: { errors: @borrowing.errors.full_messages }, status: :unprocessable_content
    end
  end

  def return_book
    if @borrowing.return!
      render json: { message: 'Book returned successfully' }
    else
      render json: { error: 'Book already returned' }, status: :unprocessable_content
    end
  end

  def dashboard
    if current_user.librarian?
      render json: {
        total_books: Book.count,
        total_borrowed: Borrowing.active.count,
        books_due_today: Borrowing.due_today.count,
        overdue_books: Borrowing.overdue.includes(:user, :book)
      }
    else
      render json: {
        my_borrowings: current_user.active_borrowings.includes(:book),
        overdue_books: current_user.overdue_books.includes(:book)
      }
    end
  end

  def overdue_members
    @overdue_borrowings = Borrowing.overdue.includes(:user, :book)
    render json: @overdue_borrowings
  end

  private

  def set_borrowing
    @borrowing = Borrowing.find(params[:id])
  end

  def authorize_librarian
    unless current_user.librarian?
      render json: { error: 'Only librarians can perform this action' }, status: :forbidden
    end
  end
end
