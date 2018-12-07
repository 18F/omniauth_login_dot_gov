module JwksWebmock
  def stub_jwks_request(body: default_jwks_response_body, status: 200)
    stub_request(:get, IdpFixtures.jwks_endpoint).
      to_return(body: body, status: status)
  end

  def default_jwks_response_body
    jwks_response_body(key: IdpFixtures.public_key_jwk)
  end

  def jwks_response_body(key:)
    { keys: [key] }.to_json
  end
end
