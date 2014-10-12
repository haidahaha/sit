class PagesController < ApplicationController
    before_action :login, only: :login_dev

    def login
        if authtoken.blank?
            client = EvernoteOAuth::Client.new
            @@request_token = client.request_token(:oauth_callback => get_auth_token_url)
            redirect_to @@request_token.authorize_url
        end
    end

    def get_auth_token
        access_token = @@request_token.get_access_token(oauth_verifier: params[:oauth_verifier])
        session[:authtoken] = access_token.token
        redirect_to root_path
    end

  def suggest
    @suggestions = params[:suggestions]
    @url = params[:url]

    if @url && @suggestions.blank?
        redirect_to action: :login_dev, controller: :pages, url: @url
    end
  end

  def login_dev
      @t1 = Time.new
      suggestions = Array.new
      client = EvernoteOAuth::Client.new(token: authtoken)
      note_store = client.note_store
      puts "1: #{timing(Time.new)}"
      if note_store
          url = params[:url]
          webpage_subjects = get_subjects_from_weburl(url)
          puts "Webpage: #{webpage_subjects.join(", ")}"

          notebooks = note_store.listNotebooks
          contact = nil
          notebooks.each do |notebook|
              if notebook.name == "Contacts"
                  contact = notebook
                  break
              end
          end
          puts "2: #{timing(Time.new)}"
          if contact
              note_filter = Evernote::EDAM::NoteStore::NoteFilter.new
              note_filter.notebookGuid = contact.guid
              note_filter.order = 2 # Evernote::EDAM::Type::NoteSortOrder.UPDATED
              note_filter.ascending = false
              notes = note_store.findNotes(note_filter, 0, 100).notes
              puts "3: #{timing(Time.new)}"

              notes.each do |note|
                  begin
                      begin
                          content = note_store.getNoteContent(note.guid)
                          hash_match = /<div style="[\S\s]+profile-image[\S\s]+?hash="([\w\d]+)"/.match(content)
                          profile_image_hash = hash_match[1]
                          resource = note_store.getResourceByHash(note.guid, profile_image_hash.unpack('a2'*(profile_image_hash.size/2)).collect {|i| i.hex.chr }.join, true, false, false)
                          profile_image = "#{resource.guid}.#{resource.mime.split("/").last}"
                          profile_image_path = Rails.root.join("public",profile_image)
                          File.open(profile_image_path, "wb") do |f|
                              f.write resource.data.body
                          end
                      rescue Exception => e
                          puts e.message
                      end
                      puts "4: #{timing(Time.new)}"
                      email_match = /href="mailto:(.*?)"/.match(content)
                      email = email_match[1]
                      name_match = /evernote:display-as;[\S\s]+?>(.*?)<\/span>/.match(content)
                      name = name_match[1]
                      puts "5: #{timing(Time.new)}"
                      tags = note_store.getNoteTagNames(note.guid)
                      puts "6: #{timing(Time.new)}"
                      puts "#{tags.join(", ")}"
                      puts "#{webpage_subjects.join(", ")}"
                      mat = WordCompare.compare_sets(webpage_subjects, tags)
                      grade = WordCompare.is_relevant(mat, 0.3)
                      puts "-------"
                      puts "#{webpage_subjects.join(", ")}"
                      puts mat
                      puts "#{tags.join(", ")}"
                      puts "-------"
                      puts "#{name}"
                      puts "#{email}"
                      puts "#{profile_image}"

                      suggestions << {grade: grade, name: name, email: email, image: profile_image}
                  rescue Exception => e
                      puts e.message
                  end
              end
          else
              puts "cannot find Contacts notebook."
          end
          if suggestions.blank?
            flash[:notice] = "Unfortunately this article may not interest your contacts! :("
            url = nil
          else
            suggestions.delete_if {|a| a[:grade] > 2 }
          end

          redirect_to action: :suggest, suggestions: suggestions, url: url
      else
        puts "There is a problem with the Internet here!"
        redirect_to action: :suggest
      end
  end

  private

  def timing(t2)
    diff = t2 - @t1
    @t1 = t2
    return diff
  end

  def get_subjects_from_weburl (url)
      hashtags = Aylien.get_hashtags(url)
      #Remove # from Hashtag and convert CamelCase to Space separated Nouns.
      return hashtags.map { |hashtag| hashtag[1..-1].gsub(/([a-z])([A-Z])/, '\1 \2') }
  end
end

