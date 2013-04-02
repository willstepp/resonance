Resonance::Application.routes.draw do
  resources :sounds
  root :to => 'home#index'
end
