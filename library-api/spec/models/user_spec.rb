require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_presence_of(:role) }
    it { should validate_inclusion_of(:role).in_array(%w[librarian member]) }
    it { should validate_presence_of(:password).on(:create) }
    it { should validate_length_of(:password).is_at_least(6).on(:create) }
  end

  describe 'associations' do
    it { should have_many(:borrowings).dependent(:destroy) }
    it { should have_many(:books).through(:borrowings) }
  end

  describe 'scopes' do
    let!(:librarian) { create(:user, :librarian) }
    let!(:member) { create(:user, :member) }

    describe '.librarians' do
      it 'returns only librarians' do
        expect(User.librarians).to include(librarian)
        expect(User.librarians).not_to include(member)
      end
    end

    describe '.members' do
      it 'returns only members' do
        expect(User.members).to include(member)
        expect(User.members).to_not include(librarian)
      end
    end
  end

  describe 'instance methods' do
    let(:librarian) { create(:user, :librarian) }
    let(:member) { create(:user, :member) }

    describe '#librarian?' do
      it 'returns true for librarian' do
        expect(librarian.librarian?).to be true
      end

      it 'returns false for member' do
        expect(member.librarian?).to be false
      end
    end

    describe '#member?' do
      it 'returns true for member' do
        expect(member.member?).to be true
      end

      it 'returns false for librarian' do
        expect(librarian.member?).to be false
      end
    end

    describe '#overdue_books' do
      let(:user) { create(:user) }
      let(:book1) { create(:book) }
      let(:book2) { create(:book) }
      let!(:overdue_borrowing) { create(:borrowing, :overdue, user: user, book: book1) }
      let!(:active_borrowing) { create(:borrowing, user: user, book: book2) }

      it 'returns overdue borrowings' do
        expect(user.overdue_books).to include(overdue_borrowing)
      end

      it 'does not return active borrowings' do
        expect(user.overdue_books).not_to include(active_borrowing)
      end
    end

    describe '#active_borrowings' do
      let(:user) { create(:user) }
      let(:book1) { create(:book) }
      let(:book2) { create(:book) }
      let!(:active_borrowing) { create(:borrowing, user: user, book: book1) }
      let!(:returned_borrowing) { create(:borrowing, :returned, user: user, book: book2) }

      it 'returns active borrowings' do
        expect(user.active_borrowings).to include(active_borrowing)
      end

      it 'does not return returned borrowings' do
        expect(user.active_borrowings).not_to include(returned_borrowing)
      end
    end
  end

  describe 'email format validation' do
    it 'accepts valid email formats' do
      user = build(:user, email: 'test@example.com')
      expect(user).to be_valid
    end

    it 'rejects invalid email formats' do
      user = build(:user, email: 'invalid-email')
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('is invalid')
    end
  end
end
