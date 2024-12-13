describe OmniAuth::LoginDotGov::IdToken do
  let(:session_nonce) { '123abc' }
  let(:session_nonce_digest) do
    OpenSSL::Digest::SHA256.base64digest(session_nonce)
  end

  let(:jwt_nonce) { session_nonce }
  let(:jwt) do
    JWT.encode({ nonce: jwt_nonce }, IdpFixtures.private_keys.first, 'RS256')
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

    context 'when the key is signed by any of the private_keys' do
      it 'returns true' do
        aggregate_failures do
          IdpFixtures.private_keys.each do |private_key|
            jwt = JWT.encode({ nonce: jwt_nonce }, private_key, 'RS256')
            expect(subject.verify_nonce(session_nonce_digest)).to eq(true)
          end
        end
      end
    end

    context 'when the key is signed by an invalid private_key' do
      let(:jwt) { JWT.encode({ nonce: jwt_nonce }, OpenSSL::PKey::RSA.new(2048), 'RS256') }
      it 'raises VerificationError' do
        expect do
          subject.verify_nonce(session_nonce_digest)
        end.to raise_error(JWT::VerificationError)
      end
    end

    context 'when the token nbf is within 10 seconds past decoding time' do
      let(:jwt) { JWT.encode({ nbf: Time.now.to_i + 10, nonce: jwt_nonce }, IdpFixtures.private_keys.first, 'RS256') }

      it 'allows 10 seconds of leeway' do
        expect(subject.verify_nonce(session_nonce_digest)).to eq true
      end
    end

    context 'when the token nbf is not within 10 seconds past decoding time' do
      let(:jwt) { JWT.encode({ nbf: Time.now.to_i + 11, nonce: jwt_nonce }, IdpFixtures.private_keys.first, 'RS256') }

      it 'raises ImmatureSignature error' do
        expect { subject.verify_nonce(session_nonce_digest) }.to raise_error(
          JWT::ImmatureSignature
        )
      end
    end
  end
end
