Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#show"

  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  post "auth/social", to: "sessions#social", as: :social_auth
  delete "logout", to: "sessions#destroy", as: :logout

  get "signup", to: "registrations#new", as: :signup
  post "signup", to: "registrations#create"

  get "password/forgot", to: "password_resets#new", as: :forgot_password
  post "password/forgot", to: "password_resets#create"
  get "password/reset", to: "password_resets#edit", as: :edit_password_reset
  patch "password/reset", to: "password_resets#update", as: :password_reset

  resources :entries, only: [:create]
  resources :tasks, only: [:index, :create, :destroy] do
    member do
      patch :toggle
    end
  end

  resources :captures, only: [:new, :create] do
    collection do
      post :preview
    end
  end

  resources :ideas, only: [:index, :show, :update, :destroy] do
    member do
      patch :confirm_steps
      patch :feature
    end
    resources :idea_steps, only: [:create]
  end

  resources :idea_steps, only: [:destroy] do
    member do
      patch :toggle
    end
  end

  resource :finances, only: [:show], controller: "finances" do
    post :create_transaction
    patch :update_budget
    delete "transactions/:id", action: :destroy_transaction, as: :transaction
  end

  resources :automation_rules, only: [:index, :create, :destroy] do
    member do
      patch :toggle
    end
  end

  get "widgets", to: "showcase#widgets", as: :widgets_showcase
  get "identity", to: "showcase#identity", as: :identity_showcase
  get "studio", to: "showcase#studio", as: :studio_showcase
end
