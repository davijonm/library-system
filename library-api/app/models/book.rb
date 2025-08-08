class Book < ApplicationRecord
  has_many :borrowings, dependent: :destroy
  has_many :users, through: :borrowings
  
  validates :title, presence: true
  validates :author, presence: true
  validates :genre, presence: true
  validates :isbn, presence: true, uniqueness: true
  validates :total_copies, presence: true, numericality: { greater_than: 0 }
  validates :available_copies, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  before_save :ensure_available_copies_not_exceed_total
  
  scope :available, -> { where('available_copies > 0') }
  scope :search_by_title, ->(title) { where('title ILIKE ?', "%#{title}%") }
  scope :search_by_author, ->(author) { where('author ILIKE ?', "%#{author}%") }
  scope :search_by_genre, ->(genre) { where('genre ILIKE ?', "%#{genre}%") }
  
  def self.search(query)
    where('title ILIKE :query OR author ILIKE :query OR genre ILIKE :query', query: "%#{query}%")
  end
  
  def borrowed_copies
    total_copies - available_copies
  end
  
  def available?
    available_copies > 0
  end
  
  def borrow!
    return false unless available?
    update!(available_copies: available_copies - 1)
  end
  
  def return!
    update!(available_copies: available_copies + 1) if available_copies < total_copies
  end
  
  private
  
  def ensure_available_copies_not_exceed_total
    if available_copies > total_copies
      errors.add(:available_copies, "cannot exceed total copies")
      throw(:abort)
    end
  end
end
