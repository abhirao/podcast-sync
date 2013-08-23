require_relative 'app_config'
require_relative 'tapas_service'
require_relative 'storage'

class Sync
  def self.run
    datastore = Storage.new
    avail = datastore.available_episodes

    service = TapasService.new
    service.feed_items(AppConfig.max_eps.to_i).each do |item|
      if avail.include? item.file_name
        puts "Skipping #{item.name} because it's already available"
      else
        service.download(item)
        datastore.upload(item)
      end
    end
  end
end
