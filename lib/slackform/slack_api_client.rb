module Slackform
  class SlackAPIClient

    def initialize(slack_api_gateway)
      @slack_api = slack_api_gateway
    end

    def channels_name_and_id_list
      @slack_api.channels_list['channels'].map { |c| "#{c['name']} => #{c['id']}" }
    end

  end
end
