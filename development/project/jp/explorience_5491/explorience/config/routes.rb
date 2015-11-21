Rails.application.routes.draw do

  devise_for :users, skip: [:registrations, :sessions], controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  devise_for :users, only: [:registrations, :sessions, :confirmations], path: 'curation', controllers: {
    registrations: "users/registrations",
    confirmations: "users/confirmations",
    sessions: "users/sessions"
  }
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  root 'top#show'
  get  'tags/(:keyword)' => 'top#show'
  get  'mypage',              action: :mypage,              controller: :top
  get  'tag_filter',          action: :add_tag_filter,      controller: :top
  get  'remove_tag',          action: :remove_tag_filter,   controller: :top
  post 'click',               action: :clicking,            controller: :clickings
  post 'click_cancel',        action: :click_cancel,        controller: :clickings
  post 'photos',              action: :create,              controller: :photos
  post 'photo_delete',        action: :destroy,             controller: :photos
  post 'upload_photo_fixed',  action: :upload_photo_fixed,  controller: :photos
  post 'update_published',    action: :update_published,    controller: :photos
  post 'twitter',             action: :twitter_post,        controller: :experiences
  get  'privacy_policy',      action: :privacy_policy,      controller: :top
  get  'setting',             action: :setting,             controller: :top
  post 'replace_rank',        action: :replace_rank,        controller: :rankings
  post 'toggle_lock',         action: :toggle_lock,         controller: :rankings
  post 'follow',              action: :follow,              controller: :follows
  get  'following_list',      action: :following_list,      controller: :follows
  get  'follower_list',       action: :follower_list,       controller: :follows
  get  'score_log',           action: :index,               controller: :score_logs
  post 'action_log_increase', action: :action_log_increase, controller: :action_logs

  # show page of experiences
  resources :experiences, only: [:show]
  # show page of users
  resources :users, only: [:show]
  # create action for invalid_images
  resources :invalid_images, only: [:create]
  # create action for affiliations
  resources :affiliations, only: [:create]
  # index page of guides
  resources :guides, only: [:index]

  # set locale
  post :set_locale, controller: :top

  # active_admin
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # for routing error
  unless Rails.env.development?
    match '*not_found' => 'errors#render_404', via: [:get, :post]
  end

  # Define route for curation

  get   'curation/experience'           => 'curation#index'
  get   'curation/experience/dashboard' => 'curation#dashboard'
  get   'curation/experience/new'       => 'curation#new'
  get   'curation/experience/:id'       => 'curation#show', as: :curation_experience_details
  post  'curation/experience'           => 'curation#create', as: :curation_experience_create
  get   'curation/experience/:id/edit'  => 'curation#edit', as: :curation_experience_edit
  match 'curation/experience/:id/update'=> 'curation#update', via: [:put, :path], as: :curation_experience_update

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

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
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
