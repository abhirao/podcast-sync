require 'yaml'
require 'dropbox_sdk'

APP_CONFIG = YAML.load_file(File.open('config.yml'))

APP_KEY = APP_CONFIG['dropbox_key']
APP_SECRET = APP_CONFIG['dropbox_secret']

ACCESS_TYPE = :app_folder
SAVED_TOKEN ='dropbox.token'

def create_or_get_session
  if File.exists?(SAVED_TOKEN)
    serialized_session = File.open(SAVED_TOKEN).read
    @session = DropboxSession.deserialize(serialized_session)
  else
    @session = DropboxSession.new(APP_KEY, APP_SECRET)
    @session.get_request_token
    authorize_url = @session.get_authorize_url

    # make the user sign in and authorize this token
    puts "AUTHORIZING", authorize_url
    puts "Please visit this website and press the 'Allow' button, then hit 'Enter' here."
    gets
    token = @session.get_access_token
    puts @session.serialize
    File.open('saved_token.yaml', 'w') {|f| f.write(@session.serialize) }
  end
end

def main
  create_or_get_session
end

main
