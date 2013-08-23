require 'dropbox_sdk'

require_relative 'app_config'

class Storage
  ACCESS_TYPE = :app_folder
  SAVED_TOKEN ='dropbox.token'

  def initialize
    @client = DropboxClient.new(get_session, ACCESS_TYPE)
  end

  def available_episodes
    avail = @client.metadata('/').fetch('contents', {}).map{|h| h.fetch('path')}.map{|ep| File.basename(ep)}
  end

  def get_session
    DropboxSession.deserialize(StringIO.new(AppConfig.dropbox_session))
  end

  def self.create_session
    session = DropboxSession.new(AppConfig.dropbox_key, AppConfig.dropbox_secret)
    session.get_request_token
    authorize_url = session.get_authorize_url

    puts "AUTHORIZING", authorize_url
    puts "Please visit this website and press the 'Allow' button, then hit 'Enter' here."
    gets
    token = session.get_access_token
    File.open(SAVED_TOKEN, 'w') {|f| f.write(session.serialize) }
    session    
  end

  def upload(item)
    @client.put_file("/#{item.file_name}", File.open(item.tmp_loc))
  end
end