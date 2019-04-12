require 'omniauth/strategies/oauth2'

module OmniAuth
  module Strategies
    class Gensdeconfiance < OmniAuth::Strategies::OAuth2
      option :name, 'gensdeconfiance'

      option :client_options, {
        :site => 'https://gensdeconfiance.fr',
        :authorize_url => 'https://gensdeconfiance.fr/oauth/v2/auth',
        :token_url => 'https://gensdeconfiance.fr/oauth/v2/token'
      }

      option :scope, 'email'
      option :fields, ['id', 'first-name', 'last-name', 'picture-url', 'email-address']
      option :authorize_options, [:state]

      uid do
        raw_info['id']
      end

      info do
        {
          :email       => raw_info["email"],
          :first_name  => raw_info["firstName"],
          :last_name   => raw_info["lastName"],
          :picture_url => raw_info["picture"]
        }
      end

      extra do
        {
          'raw_info' => raw_info
        }
      end

      def callback_url
        full_host + script_name + callback_path
      end

      alias :oauth2_access_token :access_token

      def access_token
        ::OAuth2::AccessToken.new(client, oauth2_access_token.token, {
          :expires_in => oauth2_access_token.expires_in,
          :expires_at => oauth2_access_token.expires_at
        })
      end

      def raw_info
        @raw_info ||= access_token.get(profile_endpoint).parsed
      end

      def authorize_params
        super.tap do |params|
          options[:authorize_options].each do |k|
            params[k] = request.params[k.to_s] unless [nil, ''].include?(request.params[k.to_s])
          end

          session['omniauth.state'] = params[:state] if params['state']
        end
      end

      private

      def profile_endpoint
        "/api/v2/members/me"
      end
    end
  end
end

OmniAuth.config.add_camelization 'gensdeconfiance', 'Gensdeconfiance'
