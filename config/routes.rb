Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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

  root 'index#index'

  post "register"=>"index#register"
  post "login"=>"index#login"
  post "ensure_code"=>"index#ensure_code"

  get "index"=>"index#index"
  get "home"=>"index#home"

  match 'index/create_plan'=> 'application#options_result',via: [:options]
  match 'index/create_plan_record'=> 'application#options_result',via: [:options]
  match 'index/create_or_update_alert'=> 'application#options_result',via: [:options]

  get 'index/user' => "index#user"
  post 'index/create_plan' => "index#create_plan"
  post 'index/create_plan_record' => "index#create_plan_record"
  post 'index/create_or_update_alert' => "index#create_or_update_alert"

  get  'index/plans' => "index#plans"
  get  'index/plan' => "index#plan"
  get  'index/plan_records' => "index#plan_records"

  get   "weixin/wein_login_call_back_snsapi_base"=>"weixin#wein_login_call_back_snsapi_base"
  get   "weixin/get_share_config"=>"weixin#get_share_config"

  get    "index/test1"=>"index/test1"
end
