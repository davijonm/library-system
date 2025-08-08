class Borrowing < ApplicationRecord
  belongs_to :user
  belongs_to :book
  
  validates :borrowed_at, presence: true
  validates :due_date, presence: true
  validate :user_cannot_borrow_same_book_twice, on: :create
  validate :book_must_be_available, on: :create
  validate :due_date_must_be_in_future, on: :create
  
  scope :active, -> { where(returned_at: nil) }
  scope :overdue, -> { where('due_date < ? AND returned_at IS NULL', Date.current) }
  scope :due_today, -> { where('due_date = ? AND returned_at IS NULL', Date.current) }
  
  before_create :set_borrowed_at
  before_create :set_due_date
  
  def overdue?
    due_date < Date.current && returned_at.nil?
  end
  
  def active?
    returned_at.nil?
  end
  
  def return!
    return false if returned_at.present?
    
    transaction do
      update!(returned_at: Time.current)
      book.return!
    end
  end
  
  def days_overdue
    return 0 unless overdue?
    (Date.current - due_date.to_date).to_i
  end
  
  private
  
  def user_cannot_borrow_same_book_twice
    if user.borrowings.active.exists?(book: book)
      errors.add(:base, "You have already borrowed this book")
    end
  end
  
  def book_must_be_available
    unless book.available?
      errors.add(:base, "This book is not available for borrowing")
    end
  end
  
  def due_date_must_be_in_future
    if due_date && due_date <= Date.current
      errors.add(:due_date, "must be in the future")
    end
  end
  
  def set_borrowed_at
    self.borrowed_at ||= Time.current
  end
  
  def set_due_date
    self.due_date ||= 2.weeks.from_now
  end
end
