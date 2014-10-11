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
    @subjects = get_subjects(@web_url)
  end
  
  protected
  def get_subjects (url)
    hashtags = Aylien.get_hashtags(url)
    #Remove # from Hashtag and convert CamelCase to Space separated Nouns.
    hashtags.map {|hashtag| hashtag[1..-1].gsub(/([a-z])([A-Z])/, '\1 \2')}
  end
end
