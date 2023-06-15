Rails.application.routes.draw do
  devise_for :users, path: '',
                     path_names: { sign_in: 'connexion', sign_out: 'logout' },
                     controllers: { sessions: 'sessions' }
  get '/users' => 'users#index'
  post '/import_users' => 'users#import'
  post '/select_nom' => 'users#select_nom'
  root 'pages#index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # routes statiques
  get '/mentions-legales', to: 'pages#mentions_legales'
  get '/donnees-personnelles', to: 'pages#donnees_personnelles'
  get '/accessibilite', to: 'pages#accessibilite'
  get '/plan', to: 'pages#plan'
  # routes pages erreurs
  match '/500', via: :all, to: 'errors#error_500'
  match '/404', via: :all, to: 'errors#error_404'
  match '/503', via: :all, to: 'errors#error_503'
end
