Rails.application.routes.draw do
  root 'pages#home'
  #root 'api#index'
  get 'get_user_notes' => "api#get_user_notes"
  get 'login' => "api#login"
  get 'login_dev' => "api#login_dev"
  get "suggest" => "pages#suggest"
end
