Resonance::Application.routes.draw do
  resources :mixes do
    get :processed, :on => :collection
    get :unprocessed, :on => :collection
  end

  resources :sounds do
    resources :media
  end
  
  root :to => 'home#index'
end
