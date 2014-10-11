class PagesController < ApplicationController
  def home
  end

  def suggest
    @suggestions = params[:suggestions]
    @url = params[:url]
  end

  def login_dev
      url = params[:url]
      note_store = get_note_store
      notebooks = note_store.listNotebooks
      contact = nil
      notebooks.each do |notebook|
          if notebook.name == "Contacts"
              contact = notebook
              break
          end
      end
      suggestions = Array.new
      if contact
          note_filter = Evernote::EDAM::NoteStore::NoteFilter.new
          note_filter.notebookGuid = contact.guid
          note_filter.order = 2 # Evernote::EDAM::Type::NoteSortOrder.UPDATED
          note_filter.ascending = false
          notes = note_store.findNotes(note_filter, 0, 100).notes
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
                  email_match = /href="mailto:(.*?)"/.match(content)
                  email = email_match[1]
                  name_match = /evernote:display-as;[\S\s]+?>(.*?)<\/span>/.match(content)
                  name = name_match[1]
                  tags = Array.new
                  note.tags.each do |tag|
                      tags << tag.name
                  end
                  puts "#{name}"
                  puts "#{email}"
                  puts "#{profile_image}"
                  puts "#{tags.join(", ")}"
                  suggestions << {name: name, email: email, image: profile_image}
              rescue Exception => e
                  puts e.message
              end
          end
      else
          puts "cannot find Contacts notebook."
      end
      redirect_to action: :suggest, suggestions: suggestions, url: url
  end

  private

  def get_note_store
      #developer_token = "S=s1:U=8fa63:E=1505644a850:C=148fe937a18:P=1cd:A=en-devtoken:V=2:H=a7b9d1fbe8f9e64782e855900369a0c6";
      #production
      developer_token = "S=s499:U=509daaf:E=1505643f202:C=148fe92c280:P=1cd:A=en-devtoken:V=2:H=749f4fabcb59f550cb07a06f89e8a021"
      client = EvernoteOAuth::Client.new(token: developer_token)
      note_store = client.note_store
  end

  def login
      client = EvernoteOAuth::Client.new
      request_token = client.request_token(:oauth_callback => get_user_notes_url)
      session[:request_token] = request_token
      redirect_to request_token.authorize_url
  end

  def get_user_notes
      request_token = session[:request_token]
      access_token = request_token.get_access_token(oauth_verifier: params[:oauth_verifier])
      redirect_to root_path
  end
end
