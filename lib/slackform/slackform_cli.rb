module Slackform
  class SlackformCLI < Thor

    DEFAULT_LAST_TIMESTAMP_FILE_PATH = '.last_timestamp'

    def self.config_file_option
      option :config_file,
             required: true,
             desc:     'YAML file with the configuration to run the command, see README for details.',
             banner:   'CONFIGURATION_FILE_PATH',
             aliases: '-c'
    end

    desc "invite", "check new Typeform answers and invite a new member to the Slack team for each new answer. If it finds .last_timestamp file from previous runs it will only check Typeform answers submitted after that timestamp."
    config_file_option
    option :last_timestamp_file,
           desc: 'File where the last Typeform answer timestamp is stored',
           aliases: '-t'
    def invite
      config = configuration(options[:config_file])
      last_timestamp_file = open_last_timestamp_file(options[:last_timestamp_file] || DEFAULT_LAST_TIMESTAMP_FILE_PATH)

      slack_inviter = Slackform::SlackInviter.new(slack_api_gateway(config), config.typeform_field_ids)

      if config.slack_notifier_enabled?
        slack_inviter.notifier = Slackform::Notifier::Slack.new(config.slack_notifications_webhook)
      end

      responses = typeform_api_gateway(config).responses(since: last_timestamp_file.read.chomp)
      if responses.any?
        responses.each do |response|
          slack_inviter.invite(response['answers'])
        end

        last_submit_timestamp = Time.parse("#{responses.last['metadata']['date_submit']} GMT").to_i
        last_timestamp_file.rewind
        last_timestamp_file.write(last_submit_timestamp)
        last_timestamp_file.close
      end
    end

    desc "list_slack_channels", "Get information about all Slack channels and their ID on the team. This is useful if you want to specify a list of channels to invite new members to."
    config_file_option
    def list_slack_channels
      config = configuration(options[:config_file])
      Slackform::SlackAPIClient.new(slack_api_gateway(config)).channels_name_and_id_list.each { |s| puts s }
    end

    private

    def configuration(path)
      Slackform::Configuration.new(path)
    end

    def slack_api_gateway(config)
      Slackform::ApiGateway::Slack.new(token: config.slack_api_key, slack_team: config.slack_team)
    end

    def typeform_api_gateway(config)
      Slackform::ApiGateway::Typeform.new(api_key: config.typeform_api_key, form_uid: config.typeform_uid)
    end

    def open_last_timestamp_file(path)
      File.file?(path) ? File.open(path, 'r+') : File.open(path, 'w+')
    end

  end
end
