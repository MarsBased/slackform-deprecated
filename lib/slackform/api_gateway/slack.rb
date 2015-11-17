module Slackform
  module ApiGateway
    class Slack
      include HTTParty

      def initialize(config)
        @token      = config.fetch(:token)
        @channels   = config.fetch(:channels, []).join(',')
        @slack_team = config.fetch(:slack_team)

        self.class.base_uri "https://#{@slack_team}.slack.com/api"
      end

      def invite(email, first_name, last_name)
        data = {
            email: email,
            first_name: first_name,
            last_name: last_name,
            channels: @channels,
            token: @token,
            set_active: true,
            _attempts: 1
        }
        self.class.post("/users.admin.invite?t=#{Time.now.to_i}", {body: data})
      end

      def channels_list
        data = {
            token: @token,
            exclude_archived: 1
        }
        self.class.get('/channels.list', {query: data}).parsed_response
      end
    end
  end
end

