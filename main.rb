require 'yaml'

require 'dropbox_sdk'

require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'

APP_CONFIG = YAML.load_file('config.yml')

APP_KEY = APP_CONFIG['dropbox_key']
APP_SECRET = APP_CONFIG['dropbox_secret']

APP_TAPAS_ACCT= APP_CONFIG['tapas_acct']
APP_TAPAS_PWD = APP_CONFIG['tapas_pwd']

MAX_EPS= 1
FEED_URL = "https://rubytapas.dpdcart.com/feed"

def feed_items
  content = ""
  open(FEED_URL, http_basic_authentication: [APP_TAPAS_ACCT, APP_TAPAS_PWD]) do |s| content = s.read end
  rss = RSS::Parser.parse(content, false)
  rss.channel.items.first(MAX_EPS).reverse.map{|i| {name: i.title, url: i.enclosure.url}}
end

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
    File.open(SAVED_TOKEN, 'w') {|f| f.write(@session.serialize) }
  end
end

def episode_path(ep_name)
  '/' + ep_name + '.mp4'
end

def download(item)
  puts "downloading #{item.fetch(:name)} from #{item.fetch(:url)}"
  uri =URI(item.fetch(:url))
  conn = Net::HTTP.new(uri.host, uri.port)
  conn.use_ssl=true
  conn.start do |http|
    puts "Starting Download of #{uri.request_uri}..."
    req = Net::HTTP::Get.new uri.request_uri
    req.basic_auth APP_TAPAS_ACCT, APP_TAPAS_PWD
    @file_name = uri.request_uri.gsub(/\//,'')
    puts "Downloading #{@file_name}"
    http.request req do |response|
      open(local_file, 'wb') do |io|
        response.read_body do |chunk|
          io.write chunk
        end
      end
    end
  end
end

def local_file
  File.join('tmp', @file_name)
end

def upload(client, item)
  client.put_file("#{episode_path(item.fetch(:name))}", local_file)
end

def main
  client = DropboxClient.new(create_or_get_session, ACCESS_TYPE)
  avail = client.metadata('/').fetch('contents', {}).map{|h| h.fetch('path')}

  items = feed_items
  items.each do |item|
    unless avail.include? episode_path(item.fetch(:name))
      download(item)
      upload(client, item)
    end
  end
end

main
