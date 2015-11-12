require './configuration'
require './typeform_api_gateway'
require './slack_api_gateway'
require './slack_inviter'

LAST_TIMESTAMP_FILE_PATH = '.last_timestamp'

config = Configuration.new('slackform.yml')

last_timestamp_file = if File.file?(LAST_TIMESTAMP_FILE_PATH)
                        File.open(LAST_TIMESTAMP_FILE_PATH, 'r+')
                      else
                        File.open(LAST_TIMESTAMP_FILE_PATH, 'w+')
                      end

slack_inviter = SlackInviter.new(
    SlackApiGateway.new(token: config.slack_api_key, slack_team: config.slack_team),
    config.typeform_field_ids
)

typeform_api = TypeformApiGateway.new(api_key: config.typeform_api_key, form_uid: config.typeform_uid)

responses = typeform_api.responses(since: last_timestamp_file.read.chomp)

if responses.any?
  responses.each do |response|
    slack_inviter.invite(response['answers'])
  end

  last_submit_timestamp = Time.parse("#{responses.last['metadata']['date_submit']} GMT").to_i
  last_timestamp_file.write(last_submit_timestamp)
  last_timestamp_file.close
end

# Make cli option to list channels
# p SlackInviter.new(config).channels_name_and_id_list
