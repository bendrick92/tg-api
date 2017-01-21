Rails.application.routes.draw do
  namespace :v1 do
    resources :episodes, :only => [:index, :show], :defaults => { :format => 'json' }
    resources :logs, :defaults => { :format => 'json' }
    resources :autocomplete, :defaults => { :format => 'json' }
    
    root 'episodes#index'
  end
end
