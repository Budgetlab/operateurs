Rails.application.routes.draw do
  scope(:path => '/opera') do
    devise_for :admin_users, ActiveAdmin::Devise.config
    ActiveAdmin.routes(self)
    devise_for :users, path: '',
                       path_names: { sign_in: 'connexion', sign_out: 'logout' },
                       controllers: { sessions: 'sessions' }

    get '/users' => 'users#index'
    post '/import_users' => 'users#import'
    post '/select_nom' => 'users#select_nom'
    root 'pages#index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
    post '/search_organismes' => 'organismes#search_organismes'
    resources :organismes do
      resources :chiffres, only: [:index]
      get 'restitutions', to: 'chiffres#restitutions'
      member do
        get 'enquete', to: 'organismes#enquete'
      end
    end
    post 'import_organismes' => 'organismes#import_organismes'
    resources :control_documents
    resources :objectifs_contrats
    resources :chiffres, except: [:index] do
      member do
        post :duplicate
      end
    end
    post '/show_dates' => 'chiffres#show_dates'
    post '/select_comptabilite' => 'chiffres#select_comptabilite'
    post '/select_exercice' => 'chiffres#select_exercice'
    get '/budgets-historique' => 'chiffres#historique'
    post '/update_phase' => 'chiffres#update_phase'
    get '/budgets' => 'chiffres#budgets'
    post '/open_phase' => 'chiffres#open_phase'
    get '/suivi-remplissage' => 'chiffres#suivi_remplissage'
    post '/import_operateurs' => 'operateurs#import'
    resources :ministeres
    post '/import_ministeres' => 'ministeres#import'
    get '/missions' => 'missions#index'
    post '/import_missions' => 'missions#import_missions'
    post '/select_mission' => 'missions#select_mission'
    resources :operateurs
    resources :modifications
    post 'open_modal' => 'modifications#open_modal'
    post 'filter_modifications' => 'modifications#filter_modifications'
    resources :enquete_reponses
    post '/import_reponses' => 'enquete_reponses#import'
    resources :enquete_questions
  # routes statiques
    get '/mentions-legales', to: 'pages#mentions_legales'
    get '/donnees-personnelles', to: 'pages#donnees_personnelles'
    get '/accessibilite', to: 'pages#accessibilite'
    get '/plan', to: 'pages#plan'
  # routes pages erreurs
    match '/500', via: :all, to: 'errors#error_500'
    match '/404', via: :all, to: 'errors#error_404'
    match '/503', via: :all, to: 'errors#error_503'
    match '*path', to: 'errors#error_404', via: :all
  end
  get '/', to: redirect('/opera')
end
