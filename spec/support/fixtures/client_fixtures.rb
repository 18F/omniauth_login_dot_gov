require 'openssl'

module ClientFixtures
  def self.client_id
    'urn:gov:gsa:openidconnect:sp:omniauth-test-client'
  end

  def self.private_key
    @private_key ||= OpenSSL::PKey::RSA.new(2048)
  end

  def self.public_key
    @public_key ||= private_key.public_key
  end

  def self.redirect_uri
    'http://omniauth.example.gov/auth/LoginDotGov/callback'
  end
end
