Rails.application.routes.draw do

  resources :einvoices do
    collection do
      post :issue
      get 'delay'
      post 'delay_issue'
    end

    member do
      post 'allowance'
      get 'issue_invalid'
      get 'query_issue'
      get 'query_issue_invalid'
      get 'notify'
      post 'invoice_notify'
      get 'trigger_issue'
    end

    resources :credit_notes do
      member do
        get 'allowance_invalid'
        get 'query_allowance'
        get 'query_allowance_invalid'
      end
    end
  end

  scope :controller => "api" do
    get 'index'
    get 'issue'
    get 'delay_issue'
    get 'allowance'
    get 'issue_invalid'
    get 'allowance_invalid'
    get 'query_issue'
    get 'query_issue_invalid'
    get 'query_allowance'
    get 'query_allowance_invalid'
    get 'invoice_notify'
    get 'trigger_issue'
  end

  root 'einvoices#index'

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
end
