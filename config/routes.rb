Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "trade", to: "trades#create"
      resources :infection_reports, only: [ :create ]
      resources :survivors, only: [ :create, :update ] do
        resource :inventory, only: [ :update ]
      end
    end
  end
end
