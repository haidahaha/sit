Rails.application.routes.draw do
  root 'pages#suggest'

  get 'get_auth_token' => "pages#get_auth_token"
  get 'login' => "pages#login"
  get 'login_dev' => "pages#login_dev"
  get "suggest" => "pages#suggest"
end
