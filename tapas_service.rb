require_relative 'app_config'

class TapasService
  FEED_URL = "https://rubytapas.dpdcart.com/feed"

  def self.feed_items(max=5)
    content = ""
    open(FEED_URL, http_basic_authentication: [AppConfig.tapas_acct, AppConfig.tapas_pwd]) do |s| content = s.read end
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
      req.basic_auth AppConfig.tapas_acct, AppConfig.tapas_pwd
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
