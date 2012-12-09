class AppConfig
  APP_CONFIG = YAML.load_file('config.yml')

  def self.dropbox_key
    APP_CONFIG['dropbox_key']
  end

  def self.dropbox_secret
    APP_CONFIG['dropbox_secret']
  end

  def self.tapas_acct
    APP_CONFIG['tapas_acct']
  end

  def self.tapas_pwd
    APP_CONFIG['tapas_pwd']
  end

  def self.max_eps
    1
  end
end
