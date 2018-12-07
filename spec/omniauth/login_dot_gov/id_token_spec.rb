describe OmniAuth::LoginDotGov::IdToken do
  let(:session_nonce) { '123abc' }
  let(:session_nonce_digest) do
    OpenSSL::Digest::SHA256.base64digest(session_nonce)
  end

  let(:jwt_nonce) { session_nonce }
  let(:jwt) do
    JWT.encode({ nonce: jwt_nonce }, IdpFixtures.private_key, 'RS256')
  end

  subject do
    OmniAuth::LoginDotGov::IdToken.new(
      client: MockClient.new,
      access_token: 'super-sekret-token',
      id_token: jwt,
      expires_in: 900,
      token_type: 'Bearer'
    )
  end

  describe '#verify_nonce' do
    context 'when the nonce matches the nonce in the sesison' do
      it 'returns true' do
        expect(subject.verify_nonce(session_nonce_digest)).to eq(true)
      end
    end

    context 'when the nonce does not match the nonce in the session' do
      let(:jwt_nonce) { '456def' }

      it 'raises an error' do
        expect { subject.verify_nonce(session_nonce_digest) }.to raise_error(
          OmniAuth::LoginDotGov::IdTokenNonceMismatchError
        )
      end
    end
  end
end
