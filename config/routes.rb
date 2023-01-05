Rails.application.routes.draw do

  root 'static_pages#home'

  # Login and logout routes
  get 'sso', to: 'sessions#sso', as: 'sso'

  post 'login', to: 'sessions#create', as: 'login'
  post 'logout', to: 'sessions#destroy', as: 'logout'
  get 'logout_sso', to: 'sessions#destroy_sso', as: 'logout_sso'

  if Rails.env.development?
    post 'login_hammer', to: 'sessions#create_hammer', as: 'login_hammer'
    post 'login_master', to: 'sessions#create_master', as: 'login_master'
  end

  # Games and Tools
  get 'settings', to: 'settings#index'
  get 'settings/games/:id', to: 'settings#edit_game', as: 'game'
  patch 'settings/games/:id', to: 'settings#update_game', as: 'update_game'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
