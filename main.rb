require 'yaml'

require 'dropbox_sdk'

require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'

require_relative 'app_config'
require_relative 'tapas_service'
require_relative 'storage'

def main
  datastore= Storage.new
  avail = datastore.available_episodes

  TapasService.feed_items(AppConfig.max_eps).each do |item|
    if avail.include? "/#{item.fetch(:name)}.mp4"
      puts "Skipping #{item[:name]} because it's already available"
    else
      TapasService.download(item)
      datastore.upload(client, item)
    end
  end
end

main