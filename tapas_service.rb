require_relative 'app_config'
require_relative 'feed_item'

require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'

class TapasService
  FEED_URL = "https://rubytapas.dpdcart.com/feed"

  def feed_items(max=5)
    content = ""
    open(FEED_URL, http_basic_authentication: [AppConfig.tapas_acct, AppConfig.tapas_pwd]) do |s| content = s.read end
    rss = RSS::Parser.parse(content, false)
    items = rss.channel.items.first(max).reverse.map{|i| {name: i.title, url: i.enclosure.url}}.map do |i| 
      FeedItem.new(i.fetch(:name), i.fetch(:url))
    end
  end
  
  def download(item)
    puts "downloading #{item.name} from #{item.url}"
    uri =URI(item.url)
    conn = Net::HTTP.new(uri.host, uri.port)
    conn.use_ssl=true
    conn.start do |http|
      puts "Starting Download of #{uri.request_uri}..."
      req = Net::HTTP::Get.new uri.request_uri
      req.basic_auth AppConfig.tapas_acct, AppConfig.tapas_pwd
      puts "Downloading to #{item.tmp_loc}"
      http.request req do |response|
        File.open(item.tmp_loc, 'wb') do |io|
          response.read_body do |chunk|
            io.write chunk
          end
        end
      end
    end
  end 
end
