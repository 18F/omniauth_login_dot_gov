module OmniAuth
  module LoginDotGov
    IdToken = Struct.new(
      :client,
      :access_token,
      :id_token,
      :expires_in,
      :token_type,
      keyword_init: true
    ) do
      def verify_nonce(session_nonce_digest)
        token_nonce = decoded_id_token['nonce']
        token_nonce_digest = OpenSSL::Digest::SHA256.base64digest(token_nonce)
        return true if SecureCompare.compare(
          token_nonce_digest,
          session_nonce_digest
        )
        raise IdTokenNonceMismatchError
      end

      private

      def decoded_id_token
        @decoded_id_token ||= JWT.decode(
          id_token,
          client.idp_configuration.public_key,
          true,
          algorithm: 'RS256'
        ).first
      end
    end
  end
end
