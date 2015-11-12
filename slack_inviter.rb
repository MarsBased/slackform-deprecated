require './slack_api_gateway'
require 'pry'

class SlackInviter

  def initialize(slack_api_gateway, fields_mapping)
    @slack_api = slack_api_gateway
    @fields_mapping = fields_mapping
  end

  def invite(form_answer)
    answer_data = parse_answer_data(form_answer)
    @slack_api.invite(answer_data['email'], answer_data['first_name'], answer_data['last_name'])
  end

  def channels_name_and_id_list
    @slack_api.channels_list['channels'].map { |c| "#{c['name']} => #{c['id']}" }
  end

  private

  def parse_answer_data(form_answer)
    @fields_mapping.each_with_object({}) do |(attr, field_id), answer|
      answer[attr] = form_answer[field_id]
    end
  end
end
