class FeedItem
  attr_accessor :name, :file_name, :url, :tmp_loc

  def initialize(name, url)
    @name, @url = name, url
    @file_name = name.gsub(/\//, '_') + '.mp4'
    @tmp_loc = File.join('/', 'tmp', @file_name)
  end
end