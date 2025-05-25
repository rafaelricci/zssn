Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      get "reports/infected_percentage", to: "reports#infected_percentage"
      get "reports/non_infected_percentage", to: "reports#non_infected_percentage"
      get "reports/average_items", to: "reports#average_items"
      get "reports/lost_points", to: "reports#lost_points"
      post "trade", to: "trades#create"
      resources :infection_reports, only: [ :create ]
      resources :survivors, only: [ :create, :update ] do
        resource :inventory, only: [ :update ]
      end
    end
  end
end
