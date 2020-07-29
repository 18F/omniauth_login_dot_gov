describe OmniAuth::LoginDotGov::IdpConfiguration do
  include OpenidConfigurationWebmock
  include JwksWebmock

  subject { described_class.new(idp_base_url: IdpFixtures.base_url) }

  {
    authorization_endpoint: 'http://idp.example.gov/openid_connect/authorize',
    token_endpoint: 'http://idp.example.gov/api/openid_connect/token',
    userinfo_endpoint: 'http://idp.example.gov/api/openid_connect/userinfo',
    end_session_endpoint: 'http://idp.example.gov/openid_connect/logout',
  }.each do |method, expected_result|
    describe "##{method}" do
      context 'when the configuration request is successful' do
        before { stub_openid_configuration_request }

        it 'returns the authorization endpiont' do
          result = subject.public_send(method)

          expect(result).to eq(expected_result)
        end
      end

      context 'when the configuration request fails' do
        before do
          stub_openid_configuration_request(body: 'Not found', status: 404)
        end

        it 'raises an error' do
          expect { subject.public_send(method) }.to raise_error(
            OmniAuth::LoginDotGov::OpenidDiscoveryError,
            'Openid configuration request failed with status code: 404'
          )
        end
      end
    end
  end

  describe '#public_key' do
    before { stub_openid_configuration_request }

    context 'when the certs request is successful' do
      before { stub_jwks_request }

      it 'returns the IDP public key' do
        result = subject.public_key

        expect(result.to_pem).to eq(IdpFixtures.public_key.to_pem)
      end
    end

    context 'when the certs request fails' do
      before { stub_jwks_request(body: 'Not found', status: 404) }

      it 'raises an error' do
        expect { subject.public_key }.to raise_error(
          OmniAuth::LoginDotGov::OpenidDiscoveryError,
          'JWKS request failed with status code: 404'
        )
      end
    end
  end
end
