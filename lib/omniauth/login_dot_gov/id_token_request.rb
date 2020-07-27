module OmniAuth
  module LoginDotGov
    class IdTokenRequest
      attr_reader :code, :client

      def initialize(code:, client:)
        @code = code
        @client = client
      end

      def request_id_token
        response = Faraday.post(
          client.idp_configuration.token_endpoint,
          client_assertion: client_assertion_jwt,
          client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
          code: code,
          grant_type: 'authorization_code'
        )
        raise_id_token_request_failed_error(response) unless response.success?
        id_token_from_response(response)
      end

      private

      def client_assertion_jwt
        client_id = client.client_id
        data = {
          iss: client_id,
          sub: client_id,
          aud: client.idp_configuration.token_endpoint,
          jti: SecureRandom.urlsafe_base64(32),
          exp: Time.now.to_i + 300
        }
        JWT.encode data, client.private_key, 'RS256'
      end

      def id_token_from_response(response)
        parsed_body = MultiJson.load(response.body)
        IdToken.new(
          id_token: parsed_body['id_token'],
          access_token: parsed_body['access_token'],
          client: client,
          expires_in: parsed_body['expires_in'],
          token_type: parsed_body['token_type']
        )
      end

      def raise_id_token_request_failed_error(response)
        status_code = response.status
        error_message = "Id token request failed with status code: #{status_code}"
        raise IdTokenRequestError, error_message
      end
    end
  end
end
