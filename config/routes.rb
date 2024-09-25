Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  # Rotas para a API
  # config/routes.rb
namespace :api do
  namespace :v1 do
    post 'webhooks/subscribe', to: 'webhooks#subscribe'
    post 'webhooks/validate_credentials', to: 'webhooks#validate_credentials'
  end
end

  

  # Rotas para recursos da aplicação
  resources :clients do
    collection do
      post :configure
      post :create_bill
      post :notify_payment
    end
  end
end
