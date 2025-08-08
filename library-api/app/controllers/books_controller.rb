class BooksController < ApplicationController
  before_action :set_book, only: [:show, :update, :destroy]
  before_action :authorize_librarian, only: [:create, :update, :destroy]

  def index
    if params[:search].present?
      @books = Book.search(params[:search])
    else
      @books = Book.all
    end

    render json: @books
  end

  def show
    render json: @book
  end

  def create
    @book = Book.new(book_params)
    
    if @book.save
      render json: @book, status: :created
    else
      render json: { errors: @book.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @book.update(book_params)
      render json: @book
    else
      render json: { errors: @book.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @book.destroy
    head :no_content
  end

  def search
    @books = Book.search(params[:query])
    render json: @books
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def book_params
    params.require(:book).permit(:title, :author, :genre, :isbn, :total_copies, :available_copies)
  end

  def authorize_librarian
    unless current_user.librarian?
      render json: { error: 'Only librarians can perform this action' }, status: :forbidden
    end
  end
end
