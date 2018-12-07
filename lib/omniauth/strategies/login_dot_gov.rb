module OmniAuth
  module Strategies
    class LoginDotGov
      include OmniAuth::Strategy

      option :client_id
      option :ial, 1
      option :idp_base_url, 'http://secure.login.gov'
      option :private_key
      option :redirect_uri
      option :scope, 'openid email'

      attr_reader :authorization, :callback

      uid { callback.userinfo.uuid }

      credentials do
        {
          id_token: callback.id_token.id_token,
          access_token: callback.id_token.access_token,
          expires_in: callback.id_token.expires_in,
          token_type: callback.id_token.token_type,
        }
      end

      info { callback.userinfo.to_h }

      def request_phase
        @authorization = OmniAuth::LoginDotGov::Authorization.new(
          client: client,
          session: session
        )
        redirect authorization.redirect_url
      end

      def callback_phase
        @callback = OmniAuth::LoginDotGov::Callback.new(
          session: session,
          client: client
        )
        callback.call(request.params)
        super
      rescue OmniAuth::LoginDotGov::Error => error
        fail!(error.key, error)
      end

      def client
        @client ||= OmniAuth::LoginDotGov::Client.new(
          client_id: options.client_id,
          ial: options.ial,
          idp_base_url: options.idp_base_url,
          private_key: options.private_key,
          redirect_uri: options.redirect_uri,
          scope: options.scope
        )
      end
    end
  end
end
