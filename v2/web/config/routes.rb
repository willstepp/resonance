Resonance::Application.routes.draw do
  resources :sounds do
    resources :media
  end
  root :to => 'home#index'
end
