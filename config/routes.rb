Rails.application.routes.draw do
  
  resources :promotions
  post 'payments/ephemeral_keys'
#  get 'v1/passes/*pass_type_id/:serial_number', to: 'pass_kit_api#fetch'
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'
  get 'about', to: 'welcome#about'
  get 'howitworks', to: 'welcome#howitworks'
  get 'send_gifts', to: 'welcome#send_gifts'
  get 'passes', to: 'welcome#passes'
  get 'pass/:serial_number', to: 'welcome#pass'
  get 'pass', to: 'welcome#pass_not_found'
  get 'support', to: 'welcome#support'
  
  # Redemption 
  get 'mredeem', to: 'redemption#index'
  get 'mredeem/toou', to: 'redemption#toou'
  
  # API Endpoints
  get 'api/promotions', to: 'api#promotions'
  get 'api/products', to: 'api#products'
  post 'api/requestOneTimePasscode', to: 'api#requestOneTimePasscode'
  post 'api/authenticate', to: 'api#authenticate'
  post 'api/passes', to: 'api#passes'
  post 'api/place_order', to: 'api#placeOrder'
  post 'api/order', to: 'api#order'
  post 'api/history', to: 'api#history'
  post  'api/pass/:serial_number', to: 'api#pass'
  post 'api/merchants', to: 'api#merchants'
  
  post 'api/merchant/request_passcode', to: 'merchant_api#request_passcode'
  post 'api/merchant/deauthorize', to: 'merchant_api#deauthorize_device'
  post 'api/verify_device', to: 'merchant_api#verify_device'
  post 'api/authenticate_merchant', to: 'merchant_api#authenticate_merchant'
  post 'api/authenticate_merchant_device', to: 'merchant_api#authenticate_device'
  post 'api/credits', to: 'merchant_api#credits'
  post 'api/stripe_link', to: 'merchant_api#stripe_link'
  post 'api/merchant', to: 'merchant_api#merchant'
  put 'api/merchant', to: 'merchant_api#merchant'
  post 'api/merchant/products', to: 'merchant_api#products'
  put 'api/merchant/products', to: 'merchant_api#products'
  
  
  # Redemption api endpoints
  post '/api/redemption/authorize_device', to: 'redemption_api#authorize_device'
  post '/api/redemption/redeem', to: 'redemption_api#redeem'
  post '/api/redemption/merchant_info', to: 'redemption_api#merchant_info'
  post '/api/redemption/get_code', to: 'redemption_api#get_code'
  post '/api/redemption/cancel_code', to: 'redemption_api#cancel_code'
  
  # User Routes
  get 'login', to: 'user#login'
  post 'login', to: 'user#login'
  get 'logout', to: 'user#logout'
  get 'password_reset', to: 'user#password_reset'
  get 'user/new_merchant', to: 'user#new_merchant'
  post 'user/new_merchant', to: 'user#new_merchant'
  
  
  # Admin Routes
  get 'admin', to: 'admin#index'
  post 'admin/authenticate', to: 'admin#authenticate'
  get 'admin/restricted', to: 'admin#restricted'
  
  get 'merchants/new_user', to: 'merchants#new_user'
  #post 'merchants/new_user', to: 'merchants#new_user'
  get 'merchants/enroll', to: 'merchants#enroll'
  get 'merchants/onboard1', to: 'merchants#onboard1'
  get 'merchants/onboard2', to: 'merchants#onboard2'
  get 'merchants/onboard3', to: 'merchants#onboard3'
  get 'merchants/enrollment_link', to: 'merchants#enrollment_link'
  get 'merchants/edit/:id', to: 'merchants#edit'
  post 'merchants/update', to: 'merchants#update'
  post 'merchants/update_products/:id', to: 'merchants#update_products'
  
  get 'keys/stripe_key', to: 'public_keys#stripe_key'
  get 'keys/stripe_client_id', to: 'public_keys#stripe_client_id' 
  
  resources :merchants do
    member do
      get 'stripe_dashboard_link'
    end
  end
  
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
    resources :logs
    resources :cards
  end
end
