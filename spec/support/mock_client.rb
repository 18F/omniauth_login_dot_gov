class MockClient
  attr_reader :client_id, :ial, :idp_configuration, :private_key,
              :redirect_uri, :scope, :aal

  def initialize(overrides = {})
    @client_id = ClientFixtures.client_id
    @ial = 1
    @aal = nil
    @idp_configuration = MockIdpConfiguration.new
    @private_key = ClientFixtures.private_key
    @redirect_uri = ClientFixtures.redirect_uri
    @scope = 'email openid'

    overrides.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end

  def mock_method(method_name, return_value)
    instance_variable_set("@#{method_name}", return_value)
  end
end
