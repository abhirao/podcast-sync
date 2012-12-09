require 'yaml'

require 'dropbox_sdk'

require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'

require_relative 'app_config'
require_relative 'tapas_service'
require_relative 'storage'

class Sync
  def self.run
    datastore= Storage.new
    avail = datastore.available_episodes

    TapasService.feed_items(AppConfig.max_eps.to_i).each do |item|
      if avail.include? "/#{item.name}.mp4"
        puts "Skipping #{item.name} because it's already available"
      else
        TapasService.download(item)
        datastore.upload(item)
      end
    end
  end
end
