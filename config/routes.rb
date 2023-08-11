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

  post 'games/setup', to: 'games#setup', as: 'setup_game'
  patch 'games/setup/complete', to: 'games#setup_complete', as: 'setup_game_complete'
  post 'games/unset_active_game', to: 'games#unset_active_game', as: 'unset_active_game'

  resources :games, only: [:new, :edit, :create, :update, :destroy ]

  resources :tools, only: [:new, :edit, :create, :update, :destroy ]

  resources :users, only: [:index, :edit, :update ]
  post 'users/sync_users', to: 'users#sync_users', as: 'sync_users'

  resources :factions, :except => [:show]
  post 'factions/sync_groups', to: 'factions#sync_groups', as: 'sync_groups'

  resources :armies, :except => [:show]
  get 'armies/:id/edit_notes', to: 'armies#edit_notes', as: 'edit_notes_army'
  get 'armies/:id/confirm_delete', to: 'armies#confirm', as: 'confirm_delete_army'
  get 'armies/edit_multiple', to: 'armies#edit_multiple', as: 'edit_multiple_armies'
  put 'armies/update_multiple', to: 'armies#update_multiple', as: 'update_multiple_armies'
  put 'armies/destroy_multiple', to: 'armies#destroy_multiple', as: 'destroy_multiple_armies'
  post 'armies/import', to: 'armies#import', as: 'import_armies'
  get 'armies/export', to: 'armies#export', as: 'export_armies'

  resources :locations, :except => [:show]
  get 'locations/list', to: 'locations#list', as: 'locations_list'

  resources :families, :except => [:show]

  get 'travel', to: 'travel#index'
  post 'travel/calculate', to: 'travel#calculate'

  get 'map', to: 'map#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
