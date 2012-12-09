class AppConfig
  APP_CONFIG = YAML.load_file('config.yml') if File.exists? 'config.yml'

  def self.respond_to?(message)
    [:dropbox_key, :dropbox_secret, :tapas_acct, :tapas_pwd].include? message
  end

  def self.method_missing(message)
    return ENV[message.to_s] || APP_CONFIG[message.to_s] if self.respond_to? message
    super
  end

  # def self.dropbox_key
  #   APP_CONFIG['dropbox_key']
  # end

  # def self.dropbox_secret
  #   APP_CONFIG['dropbox_secret']
  # end

  # def self.tapas_acct
  #   APP_CONFIG['tapas_acct']
  # end

  # def self.tapas_pwd
  #   APP_CONFIG['tapas_pwd']
  # end

  def self.max_eps
    1
  end
end
