require 'rails_helper'

RSpec.describe Book, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:author) }
    it { should validate_presence_of(:genre) }
    it { should validate_presence_of(:isbn) }
    it { should validate_uniqueness_of(:isbn).case_insensitive }
    it { should validate_presence_of(:total_copies) }
    it { should validate_numericality_of(:total_copies).is_greater_than(0) }
    it { should validate_presence_of(:available_copies) }
    it { should validate_numericality_of(:available_copies).is_greater_than_or_equal_to(0) }
  end

  describe 'associations' do
    it { should have_many(:borrowings).dependent(:destroy) }
    it { should have_many(:users).through(:borrowings) }
  end

  describe 'scopes' do
    let!(:available_book) { create(:book, :available) }
    let!(:unavailable_book) { create(:book, :unavailable) }

    describe '.available' do
      it 'returns only available books' do
        expect(Book.available).to include(available_book)
        expect(Book.available).not_to include(unavailable_book)
      end
    end

    describe '.search_by_title' do
      it 'finds books by title' do
        book = create(:book, title: 'Special Title')
        expect(Book.search_by_title('Special')).to include(book)
      end
    end

    describe '.search_by_author' do
      it 'finds books by author' do
        book = create(:book, author: 'Special Author')
        expect(Book.search_by_author('Special')).to include(book)
      end
    end

    describe '.search_by_genre' do
      it 'finds books by genre' do
        book = create(:book, genre: 'Special Genre')
        expect(Book.search_by_genre('Special')).to include(book)
      end
    end
  end

  describe 'instance methods' do
    let(:book) { create(:book, total_copies: 5, available_copies: 3) }

    describe '#borrowed_copies' do
      it 'returns the number of borrowed copies' do
        expect(book.borrowed_copies).to eq(2)
      end
    end

    describe '#available?' do
      it 'returns true when copies are available' do
        expect(book.available?).to be true
      end

      it 'returns false when no copies are available' do
        unavailable_book = create(:book, :unavailable)
        expect(unavailable_book.available?).to be false
      end
    end

    describe '#borrow!' do
      it 'decrements available copies' do
        expect { book.borrow! }.to change { book.available_copies }.by(-1)
      end

      it 'returns false when no copies available' do
        unavailable_book = create(:book, :unavailable)
        expect(unavailable_book.borrow!).to be false
      end
    end

    describe '#return!' do
      it 'increments available copies' do
        expect { book.return! }.to change { book.available_copies }.by(1)
      end

      it 'does not increment beyond total copies' do
        book_with_all_copies = create(:book, total_copies: 5, available_copies: 5)
        expect { book_with_all_copies.return! }.not_to change { book_with_all_copies.available_copies }
      end
    end
  end

  describe 'search functionality' do
    let!(:fiction_book) { create(:book, title: 'Fiction Book', author: 'Author A', genre: 'Fiction') }
    let!(:scifi_book) { create(:book, title: 'SciFi Book', author: 'Author B', genre: 'Science Fiction') }

    describe '.search' do
      it 'finds books by title' do
        expect(Book.search('Fiction')).to include(fiction_book)
      end

      it 'finds books by author' do
        expect(Book.search('Author A')).to include(fiction_book)
      end

      it 'finds books by genre' do
        expect(Book.search('Science Fiction')).to include(scifi_book)
      end

      it 'is case insensitive' do
        expect(Book.search('fiction')).to include(fiction_book)
      end
    end
  end

  describe 'validations' do
    describe 'available_copies validation' do
      it 'prevents available_copies from exceeding total_copies' do
        book = build(:book, total_copies: 5, available_copies: 6)
        expect(book).not_to be_valid
        expect(book.errors[:available_copies]).to include("cannot exceed total copies")
      end

      it 'allows available_copies equal to total_copies' do
        book = build(:book, total_copies: 5, available_copies: 5)
        expect(book).to be_valid
      end

      it 'allows available_copies less than total_copies' do
        book = build(:book, total_copies: 5, available_copies: 3)
        expect(book).to be_valid
      end
    end
  end
end
