require_relative 'app_config'
require_relative 'feed_item'

class TapasService
  FEED_URL = "https://rubytapas.dpdcart.com/feed"

  def self.feed_items(max=5)
    content = ""
    open(FEED_URL, http_basic_authentication: [AppConfig.tapas_acct, AppConfig.tapas_pwd]) do |s| content = s.read end
    rss = RSS::Parser.parse(content, false)
    items = rss.channel.items.first(max).reverse.map{|i| {name: i.title, url: i.enclosure.url}}.map do |i| 
      FeedItem.new(i.fetch(:name), i.fetch(:url))
    end
  end
end
