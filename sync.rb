require_relative 'app_config'
require_relative 'feeds'
require_relative 'storage'

class Sync
  def self.run
    datastore= Storage.new
    avail = datastore.available_episodes

    Feeds.feed_items(AppConfig.max_eps.to_i).each do |item|
      if avail.include? File.basename(item.local_file)
        puts "Skipping #{item.name} because it's already available"
      else
        Feeds.download(item)
        datastore.upload(item)
      end
    end
  end
end
