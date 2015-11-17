module Slackform
  module ApiGateway
    class Typeform < Base

      base_uri "https://api.typeform.com/v0/form"

      def initialize(config)
        @api_key = config.fetch(:api_key)
        @form_uid = config.fetch(:form_uid)

        self.class.default_params(key: @api_key, completed: true)
      end

      def responses(params)
        make_get("/#{@form_uid}", query: clean_params(params))['responses']
      end

      private

      def clean_params(params)
        params.delete_if { |_, v| v.to_s.empty? }
      end

    end
  end
end
