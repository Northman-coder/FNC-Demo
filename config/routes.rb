Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  devise_for :admins
  devise_for :customers, controllers: {
    sessions: "customers/sessions",
    registrations: "customers/registrations",
    passwords: "customers/passwords"
  }
  resources :products do
    member do
      patch :toggle_new_arrival
    end
  end
  resources :categories do
    member do
      delete :purge_image
    end
  end
  resource :basket, only: [:show] do
    post :add
    patch :update
    delete :remove
  end
  get "admin" => "admin#show", as: :admin_dashboard
  get  "about"   => "pages#about",   as: :about
  get  "contact" => "pages#contact", as: :contact
  get  "cookies" => "pages#cookies", as: :cookies
  resources :contact_messages, only: [:create]
  namespace :admin do
    resource :tax_setting, only: [:update]
    resource  :contact_detail, only: [:edit, :update]
    resources :messages,       only: [:index, :show, :destroy]
    resources :homepage_sections, only: [:index, :edit, :update]
    resources :customers, only: [:index]
    resources :orders, only: [:index, :show, :update]
    resources :return_items, only: [:index, :show, :update]
    resources :newsletters, only: [:new, :create]
    get "sales" => "sales#index", as: :sales
  end

  # Newsletter subscription
  post "subscribe" => "subscribers#create", as: :subscribe
  get  "unsubscribe/:token" => "subscribers#unsubscribe", as: :unsubscribe
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  get "new-arrivals" => "products#new_arrivals", as: :new_arrivals
  get "exclusive-deals" => "products#exclusive_deals", as: :exclusive_deals
  get "brands" => "products#brands", as: :brands
  get "brands/:brand" => "products#brand", as: :brand

  # customer-facing account pages
  resource :account, only: [:show], controller: 'customers'
  resources :orders, only: [:index, :show, :create] do
    member do
      patch :cancel

      # Payments
      get :pay, to: "order_payments#show"

      post "pay/stripe", to: "order_payments#stripe", as: :pay_stripe
      get  "pay/stripe/success", to: "order_payments#stripe_success", as: :pay_stripe_success
      get  "pay/stripe/cancel",  to: "order_payments#stripe_cancel",  as: :pay_stripe_cancel

      post "pay/paypal", to: "order_payments#paypal", as: :pay_paypal
      post "pay/paypal/create", to: "order_payments#paypal_create", as: :pay_paypal_create
      post "pay/paypal/capture", to: "order_payments#paypal_capture", as: :pay_paypal_capture
      get  "pay/paypal/return", to: "order_payments#paypal_return", as: :pay_paypal_return
      get  "pay/paypal/cancel", to: "order_payments#paypal_cancel", as: :pay_paypal_cancel
    end
  end

  namespace :webhooks do
    post :stripe, to: "stripe#create"
  end

  root "products#index"

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end

