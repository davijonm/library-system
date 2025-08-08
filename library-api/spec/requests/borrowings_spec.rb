require 'rails_helper'

RSpec.describe 'Borrowings', type: :request do
  let(:librarian) { create(:user, :librarian) }
  let(:member) { create(:user, :member) }
  let(:book) { create(:book, :available) }
  let(:librarian_token) { JwtService.encode({ user_id: librarian.id, email: librarian.email, role: librarian.role }) }
  let(:member_token) { JwtService.encode({ user_id: member.id, email: member.email, role: member.role }) }

  describe 'GET /borrowings' do
    let!(:borrowing) { create(:borrowing, user: member, book: book) }

    context 'with authentication' do
      it 'returns user borrowings' do
        get '/borrowings', headers: { 'Authorization' => "Bearer #{member_token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.length).to eq(1)
        expect(json.first['id']).to eq(borrowing.id)
      end
    end
  end

  describe 'GET /borrowings/:id' do
    let(:borrowing) { create(:borrowing, user: member, book: book) }

    context 'with authentication' do
      it 'returns the borrowing' do
        get "/borrowings/#{borrowing.id}", headers: { 'Authorization' => "Bearer #{member_token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['id']).to eq(borrowing.id)
      end
    end
  end

  describe 'POST /borrowings' do
    context 'when user is member' do
      let(:available_book) { create(:book, total_copies: 5, available_copies: 5) }

      it 'creates a new borrowing' do
        expect {
          post '/borrowings', params: { book_id: available_book.id }, headers: { 'Authorization' => "Bearer #{member_token}" }
        }.to change(Borrowing, :count).by(1)
      end

      it 'returns the created borrowing' do
        post '/borrowings', params: { book_id: available_book.id }, headers: { 'Authorization' => "Bearer #{member_token}" }

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['book_id']).to eq(available_book.id)
        expect(json['user_id']).to eq(member.id)
      end

      it 'decrements book available copies' do
        expect {
          post '/borrowings', params: { book_id: available_book.id }, headers: { 'Authorization' => "Bearer #{member_token}" }
        }.to change { available_book.reload.available_copies }.by(-1)
      end
    end

    context 'when book is unavailable' do
      let(:unavailable_book) { create(:book, :unavailable) }

      it 'returns validation error' do
        post '/borrowings', params: { book_id: unavailable_book.id }, headers: { 'Authorization' => "Bearer #{member_token}" }

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('This book is not available for borrowing')
      end
    end

    context 'when user already borrowed the book' do
      let(:available_book) { create(:book, total_copies: 5, available_copies: 5) }
      let!(:existing_borrowing) { create(:borrowing, user: member, book: available_book) }

      it 'returns validation error' do
        post '/borrowings', params: { book_id: available_book.id }, headers: { 'Authorization' => "Bearer #{member_token}" }

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('You have already borrowed this book')
      end
    end
  end

  describe 'PATCH /borrowings/:id/return_book' do
    let(:borrowing) { create(:borrowing, user: member, book: book) }

    context 'when user is librarian' do
      it 'marks borrowing as returned' do
        patch "/borrowings/#{borrowing.id}/return_book", headers: { 'Authorization' => "Bearer #{librarian_token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['message']).to eq('Book returned successfully')

        borrowing.reload
        expect(borrowing.returned_at).to be_present
      end

      it 'increments book available copies' do
        expect {
          patch "/borrowings/#{borrowing.id}/return_book", headers: { 'Authorization' => "Bearer #{librarian_token}" }
        }.to change { book.reload.available_copies }.by(1)
      end
    end

    context 'when user is member' do
      it 'returns forbidden' do
        patch "/borrowings/#{borrowing.id}/return_book", headers: { 'Authorization' => "Bearer #{member_token}" }

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when borrowing is already returned' do
      let(:returned_borrowing) { create(:borrowing, :returned, user: member, book: book) }

      it 'returns error' do
        patch "/borrowings/#{returned_borrowing.id}/return_book", headers: { 'Authorization' => "Bearer #{librarian_token}" }

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Book already returned')
      end
    end
  end

  describe 'GET /borrowings/dashboard' do
    context 'when user is librarian' do
      let!(:books) { create_list(:book, 3) }
      let!(:borrowings) { create_list(:borrowing, 2) }
      let!(:overdue_borrowing) { create(:borrowing, :overdue) }

      it 'returns librarian dashboard data' do
        get '/borrowings/dashboard', headers: { 'Authorization' => "Bearer #{librarian_token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['total_books']).to eq(3)
        expect(json['total_borrowed']).to eq(3)
        expect(json['overdue_books']).to be_present
      end
    end

    context 'when user is member' do
      let!(:user_borrowing) { create(:borrowing, user: member, book: book) }
      let!(:overdue_borrowing) { create(:borrowing, :overdue, user: member, book: create(:book)) }

      it 'returns member dashboard data' do
        get '/borrowings/dashboard', headers: { 'Authorization' => "Bearer #{member_token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['my_borrowings']).to be_present
        expect(json['overdue_books']).to be_present
      end
    end
  end

  describe 'GET /borrowings/overdue_members' do
    let!(:overdue_borrowing) { create(:borrowing, :overdue) }

    context 'when user is librarian' do
      it 'returns overdue borrowings' do
        get '/borrowings/overdue_members', headers: { 'Authorization' => "Bearer #{librarian_token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.length).to eq(1)
      end
    end

    context 'when user is member' do
      it 'returns forbidden' do
        get '/borrowings/overdue_members', headers: { 'Authorization' => "Bearer #{member_token}" }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
