module IdpFixtures
  def self.private_key
    @private_key ||= OpenSSL::PKey::RSA.new(2048)
  end

  def self.public_key
    @public_key ||= private_key.public_key
  end

  def self.public_key_jwk
    JSON::JWK.new(public_key)
  end

  def self.base_url
    'http://idp.example.gov/'
  end

  def self.openid_configuration_endpoint
    'http://idp.example.gov/.well-known/openid-configuration'
  end

  def self.jwks_endpoint
    'http://idp.example.gov/api/openid_connect/certs'
  end

  def self.authorization_endpoint
    'http://idp.example.gov/openid_connect/authorize'
  end

  def self.token_endpoint
    'http://idp.example.gov/api/openid_connect/token'
  end

  def self.userinfo_endpoint
    'http://idp.example.gov/api/openid_connect/userinfo'
  end
end
