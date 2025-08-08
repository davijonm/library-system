class User < ApplicationRecord
  has_secure_password
  
  has_many :borrowings, dependent: :destroy
  has_many :books, through: :borrowings
  
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }, on: :create
  validates :role, presence: true, inclusion: { in: %w[librarian member] }
  
  scope :librarians, -> { where(role: 'librarian') }
  scope :members, -> { where(role: 'member') }
  
  def librarian?
    role == 'librarian'
  end
  
  def member?
    role == 'member'
  end
  
  def overdue_books
    borrowings.where('due_date < ? AND returned_at IS NULL', Date.current)
  end
  
  def active_borrowings
    borrowings.where(returned_at: nil)
  end
end
