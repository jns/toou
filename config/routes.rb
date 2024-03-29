Rails.application.routes.draw do
  

  # You can have the root of your site routed with "root"
  root 'welcome#index'
  get 'about', to: 'welcome#index'
  get 'send_gifts', to: 'welcome#index'
  get 'passes', to: 'welcome#index'
  get 'pass', to: 'welcome#index'
  get 'pass/:serial_number', to: 'welcome#index'
  get 'password_reset(/:token)', to: 'welcome#index'

  get 'sse', to: 'sse_controller#stream'

  get 'goArmy', to: 'welcome#go_army'
  get 'goarmy', to: 'welcome#go_army'
  get 'oorah', to: 'welcome#oorah'
  get 'gonavy', to: 'welcome#go_navy'
  get 'goNavy', to: 'welcome#go_navy'
  get 'flyfightwin', to: 'welcome#flyfightwin'
  get 'bornready', to: 'welcome#bornready'

  get 'support', to: 'welcome#support'
  get "faq", to: 'welcome#faq'
  get "merchant_map", to: 'welcome#merchant_map'
  
  # Redemption 
  get 'redeem', to: 'welcome#index'
  get 'mredeem', to: 'welcome#index'
  get 'mredeem/toou', to: 'welcome#index'
  get 'mredeem/not_authorized', to: 'merchants#device_not_authorized'
  
  # API Endpoints
  post 'api/user/authenticate', to: 'user_api#authenticate'


  get 'api/promotions', to: 'api#promotions'
  get 'api/products', to: 'api#products'
  patch 'api/account', to: 'api#account'
  post 'api/account', to: 'api#account'
  post 'api/payment_methods', to: 'api#payment_methods'
  post 'api/requestOneTimePasscode', to: 'api#requestOneTimePasscode'
  post 'api/authenticate', to: 'api#authenticate'
  post 'api/passes', to: 'api#passes'
  post 'api/initiate_order', to: 'api#initiate_order'
  post 'api/confirm_payment', to: 'api#confirm_payment'
  post 'api/history', to: 'api#history'
  post  'api/pass/:serial_number', to: 'api#pass'
  post 'api/request_group_pass', to: 'api#request_group_pass'
  post 'api/merchants', to: 'api#merchants'
  post 'api/groups', to: 'api#groups'
  
  post 'api/merchant/create', to: 'merchant_api#create'
  post 'api/merchant/merchants', to: 'merchant_api#merchants'
  post 'api/merchant/deauthorize', to: 'merchant_api#deauthorize_device'
  post 'api/merchant/authorize_device', to: 'merchant_api#authorize_device'
  post 'api/merchant/authorized_devices', to: 'merchant_api#authorized_devices'
  post 'api/merchant/credits', to: 'merchant_api#credits'
  post 'api/merchant/stripe_link', to: 'merchant_api#stripe_link'
  post 'api/merchant', to: 'merchant_api#merchant'
  put 'api/merchant', to: 'merchant_api#merchant'
  post 'api/merchant/products', to: 'merchant_api#products'
  put 'api/merchant/products', to: 'merchant_api#products'
  
  # User api
  post 'api/user', to: 'user_api#get_user'
  post 'api/user/request_password_reset', to: 'user_api#request_password_reset'
  post 'api/user/password_reset', to: 'user_api#password_reset'
  post 'api/user/create_merchant_account', to: 'user_api#create_merchant_account'
  
  # Webhooks
  post '/webhook/stripe_event', to: 'stripe_webhooks#stripe_event'
  get 'merchants/enroll', to: 'stripe_webhooks#enroll'
  
  # Redemption api endpoints
  post '/api/redemption/redeem', to: 'redemption_api#redeem'
  post '/api/redemption/device_info', to: 'redemption_api#device_info'
  post '/api/redemption/merchant_info', to: 'redemption_api#merchant_info'
  post '/api/redemption/get_code', to: 'redemption_api#get_code'
  post '/api/redemption/cancel_code', to: 'redemption_api#cancel_code'
  post '/api/redemption/redeemed', to: 'redemption_api#redeemed'
  # User Routes
  get 'login', to: 'user#login'
  post 'login', to: 'user#login'
  get 'logout', to: 'user#logout'
  get 'user/new_merchant', to: 'user#new_merchant'
  post 'user/new_merchant', to: 'user#new_merchant'
  
  
  # Admin Routes
  get 'admin', to: 'admin#index'
  post 'admin/authenticate', to: 'admin#authenticate'
  get 'admin/restricted', to: 'admin#restricted'
  
  get 'merchants', to: 'welcome#index'
  get 'merchants/onboard', to: 'welcome#index'
  get 'merchants/:id', to: 'welcome#index'
  

  get 'keys/stripe_key', to: 'public_keys#stripe_key'
  get 'keys/stripe_client_id', to: 'public_keys#stripe_client_id' 
  
  # resources :merchants do
  #   member do
  #     get 'stripe_dashboard_link'
  #   end
  # end
  
  resources :password_resets, only: [:new, :edit, :create, :update]
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
    resources :merchants
  end
end
