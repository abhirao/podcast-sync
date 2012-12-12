require_relative 'tapas_service'
require_relative 'app_config'

require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'

class Feeds
  def self.feed_items(args)
    TapasService.feed_items(args)
  end

  def self.download(item)
    puts "downloading #{item.name} from #{item.url}"
    uri =URI(item.url)
    conn = Net::HTTP.new(uri.host, uri.port)
    conn.use_ssl=true
    conn.start do |http|
      puts "Starting Download of #{uri.request_uri}..."
      req = Net::HTTP::Get.new uri.request_uri
      req.basic_auth AppConfig.tapas_acct, AppConfig.tapas_pwd
      puts "Downloading to #{item.local_file}"
      http.request req do |response|
        File.open(item.local_file, 'wb') do |io|
          response.read_body do |chunk|
            io.write chunk
          end
        end
      end
    end
  end    
end