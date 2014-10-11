Rails.application.routes.draw do
  root 'pages#home'
  
  # get 'get_user_notes' => "pages#get_user_notes"
  # get 'login' => "pages#login"
  get 'login_dev' => "pages#login_dev"
  get "suggest" => "pages#suggest"
end
