Resonance::Application.routes.draw do
  resources :mixes

  resources :sounds do
    resources :media
  end
  
  root :to => 'home#index'
end
