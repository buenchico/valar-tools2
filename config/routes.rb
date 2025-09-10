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
    post 'login_nemo', to: 'sessions#create_nemo', as: 'login_nemo'
    post 'login_admin', to: 'sessions#create_master', as: 'login_admin'
  end

  # search
  resources :search, only: [:index]
  post 'search', to: 'search#search', as: 'search'

  # Games and Tools
  get 'settings', to: 'settings#index'

  post 'games/setup', to: 'games#setup', as: 'setup_game'
  patch 'games/setup/complete', to: 'games#setup_complete', as: 'setup_game_complete'
  post 'games/unset_active_game', to: 'games#unset_active_game', as: 'unset_active_game'

  resources :games, only: [:new, :edit, :create, :update, :destroy ]

  resources :tools, only: [:new, :edit, :create, :update, :destroy ]

  resources :users, only: [:index, :edit, :update, :show ]
  post 'users/sync_users', to: 'users#sync_users', as: 'sync_users'

  resources :factions
  post 'factions/sync_groups', to: 'factions#sync_groups', as: 'sync_groups'
  post 'factions/:id/reputation', to: 'factions#reputation', as: 'reputation'
  get 'factions/:id/edit_fleets_notes', to: 'factions#edit_fleets_notes', as: 'edit_fleets_notes_faction'
  patch 'factions/:id/update_fleets_notes', to: 'factions#update_fleets_notes', as: 'update_fleets_notes_faction'
  get 'factions/:id/edit_fleets', to: 'factions#edit_fleets', as: 'edit_fleets_faction'
  get 'lists/factions', to: 'factions#list', as: 'factions_list'

  #get 'armies/stats', to: 'armies#stats'
  #get 'armies/groups', to: 'armies#groups', as: 'show_army_groups'
  get 'armies/:id/edit_notes', to: 'armies#edit_notes', as: 'edit_notes_army'
  get 'armies/:id/delete', to: 'armies#delete', as: 'delete_army'
  get 'armies/edit_multiple', to: 'armies#edit_multiple', as: 'edit_multiple_armies'
  put 'armies/update_multiple', to: 'armies#update_multiple', as: 'update_multiple_armies'
  put 'armies/destroy_multiple', to: 'armies#destroy_multiple', as: 'destroy_multiple_armies'
  put 'armies/merge_multiple', to: 'armies#merge_multiple', as: 'merge_multiple_armies'
  #post 'armies/import', to: 'armies#import', as: 'import_armies'
  #get 'armies/export', to: 'armies#export', as: 'export_armies'
  #get 'armies/faction/:faction_id', to: 'armies#index'
  get 'armies/show_armies', to: 'armies#show_armies', as: 'show_armies'
  #get 'armies/get_discourse_armies/:faction_id/:group', to: 'armies#get_discourse_armies'
  #post 'armies/post_discourse_armies', to: 'armies#post_discourse_armies'
  put 'armies/damage_multiple', to: 'armies#damage_multiple', as: 'damage_multiple_armies'
  put 'armies/damage_multiple_apply', to: 'armies#damage_multiple_apply', as: 'apply_damage_multiple_armies'
  resources :armies

  get 'units/new_multiple', to: 'units#new_multiple', as: 'new_units'
  post 'units/create_multiple', to:'units#create_multiple', as: 'create_units'
  get 'units/:id/delete', to: 'units#delete', as: 'delete_unit'
  get 'units/edit_multiple', to: 'units#edit_multiple', as: 'edit_multiple_units'
  put 'units/update_multiple', to: 'units#update_multiple', as: 'update_multiple_units'
  put 'units/destroy_multiple', to: 'units#destroy_multiple', as: 'destroy_multiple_units'
  put 'units/damage_multiple', to: 'units#damage_multiple', as: 'damage_multiple_units'
  put 'units/damage_multiple_apply', to: 'units#damage_multiple_apply', as: 'apply_damage_multiple_units'
  resources :units

  resources :locations
  get '/lists/locations', to: 'locations#list', as: 'locations_list'

  get 'families/edit_multiple', to: 'families#edit_multiple', as: 'edit_multiple_families'
  post 'families/import', to: 'families#import', as: 'import_families'
  get 'families/export', to: 'families#export', as: 'export_families'
  resources :families
  get 'lists/families', to: 'families#list', as: 'families_list'

  get 'travel', to: 'travel#index'
  post 'travel/calculate', to: 'travel#calculate'

  get 'map', to: 'map#index'
  get 'map/:id', to: 'map#show'

  get 'issues', to: 'issues#new'
  post 'issues', to: 'issues#create'

  resources :battles
  get '/battles/:id/armies', to: 'battles#add_armies', as: 'add_battle_armies'
  patch '/battles/:id/armies', to: 'battles#update_armies', as: 'update_battle_armies'

  get 'clocks/edit_multiple', to: 'clocks#edit_multiple', as: 'edit_multiple_clocks'
  put 'clocks/destroy_multiple', to: 'clocks#destroy_multiple', as: 'destroy_multiple_clocks'
  resources :clocks

  get 'missions', to: 'missions#index'
  get 'missions/list', to: 'missions#list'
  get 'missions/stats', to: 'missions#stats'
  post 'missions/lists/set_mission_timer', to: 'missions#set_mission_timer', as: 'set_mission_timer'
  post 'missions/recipe', to: 'missions#get_recipe', as: 'get_recipe'
  post 'missions/calculate', to: 'missions#calculate'

  resources :recipes

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
