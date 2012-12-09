require_relative 'app_config'

class Storage
  ACCESS_TYPE = :app_folder
  SAVED_TOKEN ='dropbox.token'

  def initialize
    @client = DropboxClient.new(get_session, ACCESS_TYPE)
  end

  def available_episodes
    avail = @client.metadata('/').fetch('contents', {}).map{|h| h.fetch('path')}
  end

  def get_session
    raise "Session needs to be created and saved in #{SAVED_TOKEN}. Run Storage.create_session locally to generate it" unless File.exists?(SAVED_TOKEN)
    serialized_session = File.open(SAVED_TOKEN).read
    session = DropboxSession.deserialize(serialized_session)
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

  def upload(client, item)
    @client.put_file("/#{item.fetch(:name)}.mp4", local_file)
  end
end