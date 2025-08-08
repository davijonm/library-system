require 'rails_helper'

RSpec.describe Borrowing, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:borrowed_at) }
    it { should validate_presence_of(:due_date) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:book) }
  end

  describe 'scopes' do
    let!(:active_borrowing) { create(:borrowing, :active) }
    let!(:returned_borrowing) { create(:borrowing, :returned) }
    let!(:overdue_borrowing) { create(:borrowing, :overdue) }
    let!(:due_today_borrowing) { create(:borrowing, :due_today) }

    describe '.active' do
      it 'returns only active borrowings' do
        expect(Borrowing.active).to include(active_borrowing)
        expect(Borrowing.active).not_to include(returned_borrowing)
      end
    end

    describe '.overdue' do
      it 'returns only overdue borrowings' do
        expect(Borrowing.overdue).to include(overdue_borrowing)
        expect(Borrowing.overdue).not_to include(active_borrowing)
      end
    end

    describe '.due_today' do
      it 'returns borrowings due today' do
        expect(Borrowing.due_today).to include(due_today_borrowing)
      end
    end
  end

  describe 'instance methods' do
    let(:borrowing) { create(:borrowing) }
    let(:overdue_borrowing) { create(:borrowing, :overdue) }
    let(:returned_borrowing) { create(:borrowing, :returned) }

    describe '#overdue?' do
      it 'returns true for overdue borrowings' do
        expect(overdue_borrowing.overdue?).to be true
      end

      it 'returns false for active borrowings' do
        expect(borrowing.overdue?).to be false
      end

      it 'returns false for returned borrowings' do
        expect(returned_borrowing.overdue?).to be false
      end
    end

    describe '#active?' do
      it 'returns true for active borrowings' do
        expect(borrowing.active?).to be true
      end

      it 'returns false for returned borrowings' do
        expect(returned_borrowing.active?).to be false
      end
    end

    describe '#return!' do
      let(:book) { create(:book, available_copies: 2, total_copies: 5) }
      let(:borrowing) { create(:borrowing, book: book) }

      it 'marks borrowing as returned' do
        expect { borrowing.return! }.to change { borrowing.returned_at }.from(nil)
      end

      it 'increments book available copies' do
        expect { borrowing.return! }.to change { book.reload.available_copies }.by(1)
      end

      it 'returns false if already returned' do
        returned_borrowing = create(:borrowing, :returned)
        expect(returned_borrowing.return!).to be false
      end
    end

    describe '#days_overdue' do
      it 'returns correct number of days overdue' do
        overdue_borrowing = create(:borrowing, :overdue)
        expect(overdue_borrowing.days_overdue).to be > 0
      end

      it 'returns 0 for non-overdue borrowings' do
        expect(borrowing.days_overdue).to eq(0)
      end
    end
  end

  describe 'validations' do
    let(:user) { create(:user) }
    let(:book) { create(:book) }

    describe 'user_cannot_borrow_same_book_twice' do
      let!(:existing_borrowing) { create(:borrowing, user: user, book: book) }

      it 'prevents borrowing the same book twice' do
        new_borrowing = build(:borrowing, user: user, book: book)
        expect(new_borrowing).not_to be_valid
        expect(new_borrowing.errors[:base]).to include("You have already borrowed this book")
      end

      it 'allows borrowing after returning' do
        existing_borrowing.update!(returned_at: Time.current)
        new_borrowing = build(:borrowing, user: user, book: book)
        expect(new_borrowing).to be_valid
      end
    end

    describe 'book_must_be_available' do
      let(:unavailable_book) { create(:book, :unavailable) }

      it 'prevents borrowing unavailable books' do
        borrowing = build(:borrowing, book: unavailable_book)
        expect(borrowing).not_to be_valid
        expect(borrowing.errors[:base]).to include("This book is not available for borrowing")
      end
    end

    describe 'due_date_must_be_in_future' do
      it 'prevents due dates in the past' do
        borrowing = build(:borrowing, due_date: 1.day.ago)
        expect(borrowing).not_to be_valid
        expect(borrowing.errors[:due_date]).to include("must be in the future")
      end
    end
  end

  describe 'callbacks' do
    let(:user) { create(:user) }
    let(:book) { create(:book) }

    describe 'before_create callbacks' do
      it 'sets borrowed_at if not provided' do
        borrowing = Borrowing.new(user: user, book: book, borrowed_at: nil, due_date: 2.weeks.from_now)
        borrowing.save!
        expect(borrowing.borrowed_at).to be_present
      end

      it 'sets due_date if not provided' do
        borrowing = Borrowing.new(user: user, book: book, borrowed_at: Time.current, due_date: nil)
        borrowing.save!
        expect(borrowing.due_date).to be_present
        expect(borrowing.due_date).to be > Date.current
      end
    end
  end
end
