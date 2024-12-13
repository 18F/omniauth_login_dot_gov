describe OmniAuth::LoginDotGov::Callback do
  include TokenWebmock
  include UserinfoWebmock

  let(:client) { MockClient.new }

  let(:code) { 'code-123-abc' }
  let(:error) { nil }
  let(:error_description) { nil }
  let(:params) do
    {
      'code' => code,
      'error' => error,
      'error_description' => error_description,
      'state' => state
    }
  end

  let(:state) { 'state-123-abc' }
  let(:state_digest) { OpenSSL::Digest::SHA256.base64digest(state) }
  let(:nonce) { 'nonce-123-abc' }
  let(:nonce_digest) { OpenSSL::Digest::SHA256.base64digest(nonce) }
  let(:session) do
    {
      oidc: {
        state_digest: state_digest,
        nonce_digest: nonce_digest,
      }
    }
  end

  let(:access_token) { 'access-token-1234' }
  let(:id_token_jwt) do
    JWT.encode(
      { nonce: nonce },
      IdpFixtures.private_keys.first,
      'RS256'
    )
  end
  let(:id_token_response) do
    { access_token: access_token, id_token: id_token_jwt }.to_json
  end

  let(:userinfo_response) do
    {
      sub: '123-asdf-qwerty',
      email: 'asdf@gmail.com'
    }.to_json
  end

  subject { described_class.new(client: client, session: session) }

  before do
    stub_id_token_request(body: id_token_response, code: code)
    stub_userinfo_request(body: userinfo_response, access_token: access_token)
  end

  describe '#call' do
    context 'when the callback is successful' do
      it 'sets the id_token and userinfo' do
        subject.call(params)

        expect(subject.id_token.access_token).to eq(access_token)
        expect(subject.id_token.id_token).to eq(id_token_jwt)
        expect(subject.userinfo.uuid).to eq('123-asdf-qwerty')
        expect(subject.userinfo.email).to eq('asdf@gmail.com')
      end
    end

    context 'when the callback has an access denied error' do
      let(:code) { nil }
      let(:error) { 'access_denied' }
      let(:error_description) { 'access was denied' }

      it 'raises an access denied error' do
        expect { subject.call(params) }.to raise_error(
          OmniAuth::LoginDotGov::CallbackAccessDeniedError,
          'access was denied'
        )
      end
    end

    context 'when the callback has an invalid request error' do
      let(:code) { nil }
      let(:error) { 'invalid_request' }
      let(:error_description) { 'request was invalid' }

      it 'raises an invalid request error' do
        expect { subject.call(params) }.to raise_error(
          OmniAuth::LoginDotGov::CallbackInvalidRequestError,
          'request was invalid'
        )
      end
    end

    context 'when the callback has an unrecognized error' do
      let(:code) { nil }
      let(:error) { 'asdf' }
      let(:error_description) { 'blah blah' }

      it 'raises a runtime error' do
        expect { subject.call(params) }.to raise_error(
          RuntimeError,
          'blah blah'
        )
      end
    end

    context 'when the state does not match the session state' do
      it 'raises an error' do
        params['state'] = 'state-mismatch'

        expect { subject.call(params) }.to raise_error(
          OmniAuth::LoginDotGov::CallbackStateMismatchError
        )
      end

      it 'raises an error when the state is missing' do
        params['state'] = nil

        expect { subject.call(params) }.to raise_error(
          OmniAuth::LoginDotGov::CallbackStateMismatchError
        )
      end
    end

    context 'when serialization of session differs' do
      context 'when object keys are symbols' do
        let(:local_state_digest) { state_digest }
        let(:local_nonce_digest) { nonce_digest }
        let(:local_session) {
          {
            'oidc' => {
              'state_digest' => local_state_digest,
              'nonce_digest' => local_nonce_digest,
            }
          }.deep_symbolize_keys
        }

        subject { described_class.new(client: client, session: local_session) }

        it 'is successfully fetches session values' do
          expect(subject).to receive(:get_oidc_value_from_session).
            with(:nonce_digest).and_return(local_nonce_digest)

          expect(subject).to receive(:get_oidc_value_from_session).
            with(:state_digest).and_return(local_state_digest)

          subject.call(params)
        end
      end

      context 'when object keys are strings' do
        let(:local_state_digest) { state_digest }
        let(:local_nonce_digest) { nonce_digest }
        let(:local_session) {
          {
            'oidc' => {
              'state_digest' => local_state_digest,
              'nonce_digest' => local_nonce_digest,
            }
          }
        }

        subject { described_class.new(client: client, session: local_session) }

        it 'is successfully fetches session values' do
          expect(subject).to receive(:get_oidc_value_from_session).
            with(:nonce_digest).and_return(local_nonce_digest)

          expect(subject).to receive(:get_oidc_value_from_session).
            with(:state_digest).and_return(local_state_digest)

          subject.call(params)
        end
      end
    end
  end
end
