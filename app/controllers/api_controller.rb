class ApiController < ApplicationController
    def index
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

    def login_dev
        note_store = get_note_store
        notebooks = note_store.listNotebooks
        contact = nil
        notebooks.each do |notebook|
            if notebook.name == "My Notebook"
                contact = notebook
            end
        end
        if contact
            note_filter = Evernote::EDAM::NoteStore::NoteFilter.new
            note_filter.notebookGuid = contact.guid
            notes = note_store.findNotes(note_filter, 0, 100).notes
            notes.each do |note|
                puts "#{note.title} | #{note.tagNames}"
                #puts "#{note_store.getNoteContent(note.guid)}"
                if note.resources
                    note.resources.each do |resource|
                        puts "#{resource.data.bodyHash.hex}"
                    end
                end
            end
            hash_func = Digest::MD5.new
            dig = hash_func.digest("foo")
            hexdig = hash_func.hexdigest("foo")
            puts "#{dig} | #{hexdig} | #{hexdig.unpack('a2'*(hexdig.size/2)).collect {|i| i.hex.chr }.join}"

        else
            puts "cannot find Contacts notebook."
        end
    end

    private

    def get_note_store
        #developer_token = "S=s1:U=8fa4f:E=15055172e4e:C=148fd660250:P=1cd:A=en-devtoken:V=2:H=b063080b9129f0348b1eb78ee194668b";
        #production
        developer_token = "S=s93:U=9a681a:E=1505556ebde:C=148fda5beb8:P=1cd:A=en-devtoken:V=2:H=ed02fe3c29f1a6a4a36929c6ae15f490"
        client = EvernoteOAuth::Client.new(token: developer_token)
        note_store = client.note_store
    end
end
