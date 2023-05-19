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
  resources :games, only: [:new, :edit, :create, :update, :destroy ]
  post 'games/set_active_game', to: 'games#set_active_game', as: 'set_active_game'
  post 'games/unset_active_game', to: 'games#unset_active_game', as: 'unset_active_game'
  resources :tools, only: [:new, :edit, :create, :update, :destroy ]

  resources :armies
  get 'armies/:id/edit_notes', to: 'armies#edit_notes', as: 'edit_notes_army'

  resources :factions, only: [:index, :edit, :update]

  get 'travel', to: 'travel#index'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
