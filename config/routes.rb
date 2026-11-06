Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#show"

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
