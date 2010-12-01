Rails.application.routes.draw do
  namespace :admin do
     resources :orders do
       member do
         get :tracking
         get :reload_tracking
       end
     end
  end
end
