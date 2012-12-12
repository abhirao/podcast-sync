require 'yaml'

class AppConfig
  APP_CONFIG = YAML.load_file('config.yml') if File.exists? 'config.yml'

  def self.respond_to?(message)
    [:dropbox_key, :dropbox_secret, :dropbox_session, :tapas_acct, :tapas_pwd, :max_eps].include? message
  end

  def self.method_missing(message)
    return ENV[message.to_s] || APP_CONFIG[message.to_s] if self.respond_to? message
    super
  end
end
