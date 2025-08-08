Rails.application.routes.draw do
  # authentication routes
  post '/register', to: 'auth#register'
  post '/login', to: 'auth#login'
  post '/logout', to: 'auth#logout'

  # books routes
  resources :books, only: [:index, :show, :create, :update, :destroy] do
    collection do
      get :search
    end
  end

  # borrowings routes
  resources :borrowings, only: [:index, :show, :create] do
    member do
      patch :return_book
    end
    collection do
      get :dashboard
      get :overdue_members
    end
  end
end
