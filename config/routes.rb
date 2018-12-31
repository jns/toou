Rails.application.routes.draw do
  resources :orders
  resources :passes
  resources :accounts
  
  get 'v1/passes/*pass_type_id/:serial_number', to: 'passes#fetch'
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'
  get 'about', to: 'welcome#about'
  
  # API Endpoints
  post 'api/requestOneTimePasscode', to: 'api#requestOneTimePasscode'
  post 'api/authenticate', to: 'api#authenticate'
  post 'api/passes', to: 'api#passes'
  post 'api/place_order', to: 'api#placeOrder'
  post 'api/history', to: 'api#history'
  
  # Admin Routes
  get 'admin', to: 'admin#index'
  get 'admin/login', to: 'admin#login'
  get 'admin/logout', to: 'admin#logout'
  post 'admin/authenticate', to: 'admin#authenticate'
  get 'admin/restricted', to: 'admin#restricted'
  
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
  namespace :admin do
    # Directs /admin/passes/* to Admin::PassesController
    # (app/controllers/admin/passes_controller.rb)
    resources :passes
    resources :orders
    resources :accounts
  end
end
