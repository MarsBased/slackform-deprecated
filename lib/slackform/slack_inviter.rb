module Slackform
  class SlackInviter

    Invitation = Struct.new(:first_name, :last_name, :email) do

      def full_name
        "#{first_name} #{last_name}"
      end

    end

    attr_writer :notifier

    def initialize(slack_api_gateway, fields_mapping, notifier = Slackform::Notifier::Default.new)
      @slack_api = slack_api_gateway
      @fields_mapping = fields_mapping
      @notifier = notifier
    end

    def invite(form_answer)
      invitation = parse_answer_data(form_answer)

      response = @slack_api.invite(invitation.email, invitation.first_name, invitation.last_name)

      handle_invite_response(invitation, response)
    end

    def channels_name_and_id_list
      @slack_api.channels_list['channels'].map { |c| "#{c['name']} => #{c['id']}" }
    end

    private

    def parse_answer_data(form_answer)
      @fields_mapping.each_with_object(Invitation.new) do |(attr, field_id), invitation|
        invitation[attr] = form_answer[field_id]
      end
    end

    def handle_invite_response(invitation, response)
      if response['ok']
        @notifier.notify_successful_invitation(invitation.full_name, invitation.email)
      else
        @notifier.notify_failed_invitation(invitation.full_name, invitation.email, response['error'])
      end
    end
  end
end
