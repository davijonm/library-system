require 'rails_helper'

RSpec.describe 'Auth', type: :request do
  describe 'POST /register' do
    let(:valid_params) do
      {
        user: {
          email: 'test@example.com',
          password: 'password123',
          role: 'member'
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new user' do
        expect {
          post '/register', params: valid_params
        }.to change(User, :count).by(1)
      end

      it 'returns the user data and token' do
        post '/register', params: valid_params

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['user']['email']).to eq('test@example.com')
        expect(json['user']['role']).to eq('member')
        expect(json['token']).to be_present
      end
    end

    context 'with invalid parameters' do
      it 'returns validation errors for invalid email' do
        post '/register', params: {
          user: {
            email: 'invalid-email',
            password: 'password123',
            role: 'member'
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('Email is invalid')
      end

      it 'returns validation errors for short password' do
        post '/register', params: {
          user: {
            email: 'test@example.com',
            password: '123',
            role: 'member'
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('Password is too short (minimum is 6 characters)')
      end

      it 'returns validation errors for invalid role' do
        post '/register', params: {
          user: {
            email: 'test@example.com',
            password: 'password123',
            role: 'invalid_role'
          }
        }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('Role is not included in the list')
      end
    end

    context 'with duplicate email' do
      let!(:existing_user) { create(:user, email: 'test@example.com') }

      it 'returns validation error' do
        post '/register', params: valid_params

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('Email has already been taken')
      end
    end
  end

  describe 'POST /login' do
    let!(:user) { create(:user, email: 'test@example.com', password: 'password123') }

    context 'with valid credentials' do
      it 'returns user data and token' do
        post '/login', params: {
          email: 'test@example.com',
          password: 'password123'
        }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['user']['email']).to eq('test@example.com')
        expect(json['token']).to be_present
      end
    end

    context 'with invalid email' do
      it 'returns unauthorized error' do
        post '/login', params: {
          email: 'wrong@example.com',
          password: 'password123'
        }

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Invalid email or password')
      end
    end

    context 'with invalid password' do
      it 'returns unauthorized error' do
        post '/login', params: {
          email: 'test@example.com',
          password: 'wrongpassword'
        }

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Invalid email or password')
      end
    end
  end

  describe 'POST /logout' do
    let(:user) { create(:user) }
    let(:token) { JwtService.encode({ user_id: user.id, email: user.email, role: user.role }) }

    it 'returns success message' do
      post '/logout', headers: { 'Authorization' => "Bearer #{token}" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['message']).to eq('Logged out successfully')
    end
  end
end
