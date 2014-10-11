class SharingsController < ApplicationController
  def index
    @suggested_people = [
        {:first_name => "Max",
         :last_name => "Mustermann",
         :mail_adress => "max@mustermann.ch",
         :profile_pic => "http://www.example.com/image.jpg",
         :account_link => "http://www.linkedin.org/test"
         },
         {:first_name => "Mia",
         :last_name => "Musterfrau",
         :mail_adress => "Mia@mustermann.ch",
         :profile_pic => "http://www.example.com/image.jpg",
         :account_link => "http://www.linkedin.org/test"
         },
         {:first_name => "Fred",
         :last_name => "Musterklug",
         :mail_adress => "Fred@mustermann.ch",
         :profile_pic => "http://www.example.com/image.jpg",
         :account_link => "http://www.linkedin.org/test"
         }
     ]
    @web_url = "http://www.google.com"
  end
end
