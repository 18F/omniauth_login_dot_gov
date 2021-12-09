module OmniAuth
  module LoginDotGov
    class Authorization
      attr_reader :session, :client
      VALID_AAL_VALUES = %w[2 3 3-hspd12].freeze

      def initialize(session:, client:)
        @session = session
        @client = client
      end

      def redirect_url
        uri = URI.parse(client.idp_configuration.authorization_endpoint)
        uri.query = redirect_url_params.to_query
        uri.to_s
      end

      private

      def redirect_url_params
        {
          acr_values: acr_values,
          client_id: client.client_id,
          response_type: 'code',
          redirect_uri: client.redirect_uri,
          scope: client.scope,
          state: state,
          nonce: nonce,
        }
      end

      def aal
        if client.aal.nil?
          nil
        elsif VALID_AAL_VALUES.include?(client.aal.to_s)
          client.aal.to_s
        else
          raise "Invalid AAL, choose one of #{VALID_AAL_VALUES}"
        end
      end

      def acr_values
        values = []

        values << if client.ial == 2
          'http://idmanagement.gov/ns/assurance/loa/3'
        else
          'http://idmanagement.gov/ns/assurance/loa/1'
        end

        values << case aal
        when '2'
          'http://idmanagement.gov/ns/assurance/aal/2'
        when '3'
          'http://idmanagement.gov/ns/assurance/aal/3'
        when '3-hspd12'
          'http://idmanagement.gov/ns/assurance/aal/3?hspd12=true'
        end

        values.join(' ').strip
      end

      def state
        @state ||= begin
          state_value = SecureRandom.urlsafe_base64(48)
          state_digest = OpenSSL::Digest::SHA256.base64digest(state_value)
          session[:oidc] ||= {}
          session[:oidc][:state_digest] = state_digest
          state_value
        end
      end

      def nonce
        @nonce ||= begin
          state_value = SecureRandom.urlsafe_base64(24)
          state_digest = OpenSSL::Digest::SHA256.base64digest(state_value)
          session[:oidc] ||= {}
          session[:oidc][:nonce_digest] = state_digest
          state_value
        end
      end
    end
  end
end
