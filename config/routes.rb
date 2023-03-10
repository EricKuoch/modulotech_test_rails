Rails.application.routes.draw do
  devise_for :users
  health_check_routes

  root "rooms#index"
  resources :rooms do
    resources :bookings, only: [:create,:delete]
  end

  #resources :rooms, only: %i[index show]
end
