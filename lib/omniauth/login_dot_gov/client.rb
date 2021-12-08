module OmniAuth
  module LoginDotGov
    class Client
      attr_reader :client_id, :ial, :idp_configuration, :private_key,
                  :redirect_uri, :scope, :aal

      def initialize(
        client_id:,
        ial:,
        idp_base_url:,
        private_key:,
        redirect_uri:,
        scope:,
        aal: nil
      )
        @client_id = client_id
        @ial = ial
        @aal = aal
        @idp_configuration = IdpConfiguration.new(idp_base_url: idp_base_url)
        @private_key = private_key
        @redirect_uri = redirect_uri
        @scope = scope
      end
    end
  end
end
