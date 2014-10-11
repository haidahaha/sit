Rails.application.routes.draw do
  root 'pages#home'
  #root 'sharings#index'
  resources :sharings
  # get 'get_user_notes' => "pages#get_user_notes"
  # get 'login' => "pages#login"
  post 'login_dev' => "pages#login_dev"
  get "suggest" => "pages#suggest"
end
