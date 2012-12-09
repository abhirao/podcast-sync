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

class TapasService
  FEED_URL = "https://rubytapas.dpdcart.com/feed"

  def self.feed_items(max=5)
    content = ""
    open(FEED_URL, http_basic_authentication: [APP_TAPAS_ACCT, APP_TAPAS_PWD]) do |s| content = s.read end
    rss = RSS::Parser.parse(content, false)
    rss.channel.items.first(max).reverse.map{|i| {name: i.title, url: i.enclosure.url}}
  end

  def self.download(item)
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

  private
  def local_file
    File.join('tmp', @file_name)
  end
end

class Storage
  ACCESS_TYPE = :app_folder
  SAVED_TOKEN ='dropbox.token'

  def initialize
    @client = DropboxClient.new(create_or_get_session, ACCESS_TYPE)
  end

  def available_episodes
    avail = @client.metadata('/').fetch('contents', {}).map{|h| h.fetch('path')}
  end

  def create_or_get_session
    if File.exists?(SAVED_TOKEN)
      serialized_session = File.open(SAVED_TOKEN).read
      session = DropboxSession.deserialize(serialized_session)
    else
      session = DropboxSession.new(APP_KEY, APP_SECRET)
      session.get_request_token
      authorize_url = session.get_authorize_url

      # make the user sign in and authorize this token
      puts "AUTHORIZING", authorize_url
      puts "Please visit this website and press the 'Allow' button, then hit 'Enter' here."
      gets
      token = session.get_access_token
      File.open(SAVED_TOKEN, 'w') {|f| f.write(session.serialize) }
      session
    end
  end

  def upload(client, item)
    @client.put_file("/#{item.fetch(:name)}.mp4", local_file)
  end
end

def main
  datastore= Storage.new
  avail = datastore.available_episodes

  TapasService.feed_items(MAX_EPS).each do |item|
    if avail.include? "/#{item.fetch(:name)}.mp4"
      puts "Skipping #{item[:name]} because it's already available"
    else
      TapasService.download(item)
      datastore.upload(client, item)
    end
  end
end

main
