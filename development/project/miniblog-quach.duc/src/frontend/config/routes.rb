Rails.application.routes.draw do

  # Define route config for register, login, logout
  get "log_out"   => "sessions#destroy", :as => "log_out"
  get "log_in"     => "sessions#new",      :as => "log_in"

  get "sign_up"  => "users#new",          :as => "sign_up"

  get "edit_user_info/:id"   => "users#edit",          :as => "edit_user_info"
  get "edit_user_pass/:id"  => "users#edit",          :as => "edit_user_pass"

  get 'list_users'  => 'home#user_index'
  root 'home#index'

  get       'categories/:tag',       to: 'posts#tagged', as: :tag

  resources :users

  resources :sessions

  resources :comments

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"

  # Example of regular route:

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  resources :posts

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
    # concern :toggleable do
    #    get 'posts'
    # end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
