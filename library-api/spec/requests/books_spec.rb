require 'rails_helper'

RSpec.describe 'Books', type: :request do
  let(:librarian) { create(:user, :librarian) }
  let(:member) { create(:user, :member) }
  let(:book) { create(:book) }
  let(:valid_token) { JwtService.encode({ user_id: librarian.id, email: librarian.email, role: librarian.role }) }
  let(:member_token) { JwtService.encode({ user_id: member.id, email: member.email, role: member.role }) }

  describe 'GET /books' do
    let!(:books) { create_list(:book, 3) }

    context 'without authentication' do
      it 'returns unauthorized' do
        get '/books'
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with invalid token' do
      it 'returns unauthorized' do
        get '/books', headers: { 'Authorization' => 'Bearer invalid_token' }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with authentication' do
      it 'returns all books' do
        get '/books', headers: { 'Authorization' => "Bearer #{valid_token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.length).to eq(3)
      end

      it 'returns filtered books when search parameter is provided' do
        book = create(:book, title: 'Special Book')

        get '/books', params: { search: 'Special' }, headers: { 'Authorization' => "Bearer #{valid_token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json.length).to eq(1)
        expect(json.first['title']).to eq('Special Book')
      end
    end
  end

  describe 'GET /books/:id' do
    context 'with authentication' do
      it 'returns the book' do
        get "/books/#{book.id}", headers: { 'Authorization' => "Bearer #{valid_token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['id']).to eq(book.id)
        expect(json['title']).to eq(book.title)
      end

      it 'returns not found for non-existent book' do
        get '/books/999', headers: { 'Authorization' => "Bearer #{valid_token}" }

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /books' do
    let(:valid_params) do
      {
        book: {
          title: 'New Book',
          author: 'New Author',
          genre: 'Fiction',
          isbn: '978-1234567890',
          total_copies: 5,
          available_copies: 5
        }
      }
    end

    context 'when user is librarian' do
      it 'creates a new book' do
        expect {
          post '/books', params: valid_params, headers: { 'Authorization' => "Bearer #{valid_token}" }
        }.to change(Book, :count).by(1)
      end

      it 'returns the created book' do
        post '/books', params: valid_params, headers: { 'Authorization' => "Bearer #{valid_token}" }

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['title']).to eq('New Book')
        expect(json['author']).to eq('New Author')
      end
    end

    context 'when user is member' do
      it 'returns forbidden' do
        post '/books', params: valid_params, headers: { 'Authorization' => "Bearer #{member_token}" }

        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Only librarians can perform this action')
      end
    end

    context 'with invalid parameters' do
      it 'returns validation errors' do
        post '/books', params: {
          book: {
            title: '',
            author: '',
            isbn: 'invalid-isbn'
          }
        }, headers: { 'Authorization' => "Bearer #{valid_token}" }

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Title can't be blank")
        expect(json['errors']).to include("Author can't be blank")
      end
    end
  end

  describe 'PUT /books/:id' do
    let(:update_params) do
      {
        book: {
          title: 'Updated Book',
          author: 'Updated Author'
        }
      }
    end

    context 'when user is librarian' do
      it 'updates the book' do
        put "/books/#{book.id}", params: update_params, headers: { 'Authorization' => "Bearer #{valid_token}" }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['title']).to eq('Updated Book')
        expect(json['author']).to eq('Updated Author')
      end
    end

    context 'when user is member' do
      it 'returns forbidden' do
        put "/books/#{book.id}", params: update_params, headers: { 'Authorization' => "Bearer #{member_token}" }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE /books/:id' do
    context 'when user is librarian' do
      it 'deletes the book' do
        book_to_delete = create(:book)

        expect {
          delete "/books/#{book_to_delete.id}", headers: { 'Authorization' => "Bearer #{valid_token}" }
        }.to change(Book, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when user is member' do
      it 'returns forbidden' do
        delete "/books/#{book.id}", headers: { 'Authorization' => "Bearer #{member_token}" }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'GET /books/search' do
    let!(:fiction_book) { create(:book, title: 'Fiction Book', author: 'Author A', genre: 'Fiction') }
    let!(:scifi_book) { create(:book, title: 'SciFi Book', author: 'Author B', genre: 'Science Fiction') }

    it 'returns books matching the query' do
      get '/books/search', params: { query: 'Fiction' }, headers: { 'Authorization' => "Bearer #{valid_token}" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(1)
      expect(json.first['title']).to eq('Fiction Book')
    end

    it 'returns empty array for no matches' do
      get '/books/search', params: { query: 'NonExistent' }, headers: { 'Authorization' => "Bearer #{valid_token}" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to be_empty
    end

    it 'returns all books when query matches multiple' do
      get '/books/search', params: { query: 'Book' }, headers: { 'Authorization' => "Bearer #{valid_token}" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.length).to eq(2)
    end
  end
end
