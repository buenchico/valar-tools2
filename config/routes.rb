Rails.application.routes.draw do

  root 'static_pages#home'

  # Errors
  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server", via: :all

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

  resources :factions
  post 'factions/sync_groups', to: 'factions#sync_groups', as: 'sync_groups'
  post 'factions/:id/reputation', to: 'factions#reputation', as: 'reputation'
  get 'factions/:id/edit_fleets_notes', to: 'factions#edit_fleets_notes', as: 'edit_fleets_notes_faction'
  patch 'factions/:id/update_fleets_notes', to: 'factions#update_fleets_notes', as: 'update_fleets_notes_faction'
  get 'factions/:id/edit_fleets', to: 'factions#edit_fleets', as: 'edit_fleets_faction'
  get 'lists/factions', to: 'factions#list', as: 'factions_list'


  get 'armies/:id/edit_notes', to: 'armies#edit_notes', as: 'edit_notes_army'
  get 'armies/:id/confirm_delete', to: 'armies#confirm', as: 'confirm_delete_army'
  get 'armies/edit_multiple', to: 'armies#edit_multiple', as: 'edit_multiple_armies'
  put 'armies/update_multiple', to: 'armies#update_multiple', as: 'update_multiple_armies'
  put 'armies/destroy_multiple', to: 'armies#destroy_multiple', as: 'destroy_multiple_armies'
  post 'armies/import', to: 'armies#import', as: 'import_armies'
  get 'armies/export', to: 'armies#export', as: 'export_armies'
  get 'armies/faction/:faction_id', to: 'armies#index'
  get 'armies/get_armies', to: 'armies#get_armies', as: 'get_armies'
  get 'armies/get_discourse_armies/:faction_id/:group', to: 'armies#get_discourse_armies'
  post 'armies/post_discourse_armies', to: 'armies#post_discourse_armies'
  resources :armies, :except => [:show]

  resources :locations
  get '/lists/locations', to: 'locations#list', as: 'locations_list'

  resources :families
  get 'lists/families', to: 'families#list', as: 'families_list'

  get 'travel', to: 'travel#index'
  post 'travel/calculate', to: 'travel#calculate'

  get 'map', to: 'map#index'
  get 'map/:id', to: 'map#show'

  get 'issues', to: 'issues#new'
  post 'issues', to: 'issues#create'

  resources :battles

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
