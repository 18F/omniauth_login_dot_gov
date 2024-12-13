describe OmniAuth::LoginDotGov::IdTokenRequest do
  include TokenWebmock

  let(:client) { MockClient.new }
  let(:code) { 'authorization-code-1234' }

  # Response values
  let(:access_token) { 'access-token-1234' }
  let(:id_token_jwt) do
    JWT.encode({ asdf: 1234 }, IdpFixtures.private_keys.first, 'RS256')
  end
  let(:token_response_body) do
    {
      access_token: access_token,
      id_token: id_token_jwt,
      expires_in: 900,
      token_type: 'bearer'
    }.to_json
  end

  subject { described_class.new(code: code, client: client) }

  describe '#request_id_token' do
    context 'when the request is successful' do
      before { stub_id_token_request(code: code, body: token_response_body) }

      it 'returns an id token' do
        id_token = subject.request_id_token

        expect(id_token.access_token).to eq(access_token)
        expect(id_token.id_token).to eq(id_token_jwt)
        expect(id_token.expires_in).to eq(900)
        expect(id_token.token_type).to eq('bearer')
      end
    end

    context 'when the request fails' do
      before do
        stub_id_token_request(
          code: code,
          body: 'Error: bad request',
          status: 400
        )
      end

      it 'raises an error' do
        expect { subject.request_id_token }.to raise_error(
          OmniAuth::LoginDotGov::IdTokenRequestError,
          'Id token request failed with status code: 400'
        )
      end
    end
  end
end
