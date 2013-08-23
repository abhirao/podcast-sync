require 'open-uri'

class FeedItem
  attr_accessor :name, :file_name, :url, :tmp_loc

  def initialize(name, url)
    @name, @url = name, url
    @file_name = name.gsub(/\//, '_') + '.mp4'
    @tmp_loc = File.join('/', 'tmp', @file_name)
  end
  
  def download
    puts "downloading #{name} from #{url}"
    uri = URI(url)
    conn = Net::HTTP.new(uri.host, uri.port)
    conn.use_ssl=true
    conn.start do |http|
      puts "Starting Download of #{uri.request_uri}..."
      req = Net::HTTP::Get.new uri.request_uri
      req.basic_auth AppConfig.tapas_acct, AppConfig.tapas_pwd
      puts "Downloading to #{tmp_loc}"
      http.request req do |response|
        File.open(tmp_loc, 'wb') do |io|
          response.read_body do |chunk|
            io.write chunk
          end
        end
      end
    end
  end    
end