require 'yaml'

class Configuration

  def initialize(config_file_path)
    @config_file_path = config_file_path
  end

  def typeform_api_key
    configuration['typeform_api_key']
  end

  def typeform_uid
    configuration['typeform_uid']
  end

  def slack_api_key
    configuration['slack_api_key']
  end

  def slack_team
    configuration['slack_team']
  end

  def slack_channels
    configuration['slack_channels']
  end

  def typeform_field_ids
    configuration['typeform_field_ids']
  end

  private

  def configuration
    @configuration ||= YAML.load_file(@config_file_path)
  end
end
