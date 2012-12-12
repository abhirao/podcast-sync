class FeedItem
  attr_accessor :name, :local_file, :url

  def initialize(name, local_file, url)
    @name, @local_file, @url = name, local_file, url
  end
end