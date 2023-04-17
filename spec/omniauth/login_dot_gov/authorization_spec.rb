describe OmniAuth::LoginDotGov::Authorization do
  let(:aal) { nil }
  let(:client) { MockClient.new({aal: aal}) }
  let(:session) { {} }

  subject { described_class.new(session: session, client: client) }

  describe '#auth_url' do
    it 'returns an auth URL and saves the nonce and state in the session' do
      auth_uri = URI.parse(subject.redirect_url)

      expect(auth_uri.hostname).to eq('idp.example.gov')
      expect(auth_uri.path).to eq('/openid_connect/authorize')

      params = Rack::Utils.parse_query(auth_uri.query)

      expect(params['acr_values']).to eq('http://idmanagement.gov/ns/assurance/loa/1')
      expect(params['client_id']).to eq('urn:gov:gsa:openidconnect:sp:omniauth-test-client')
      expect(params['response_type']).to eq('code')
      expect(params['redirect_uri']).to eq('http://omniauth.example.gov/auth/LoginDotGov/callback')

      scope = params['scope'].split(' ')
      expect(scope).to include('openid')
      expect(scope).to include('email')

      expect(params['nonce']).to_not be_blank
      expect(params['nonce'].length).to eq(32)
      nonce_digest = OpenSSL::Digest::SHA256.base64digest(params['nonce'])
      expect(nonce_digest).to eq(session[:oidc][:nonce_digest])

      expect(params['state']).to_not be_blank
      state_digest = OpenSSL::Digest::SHA256.base64digest(params['state'])
      expect(state_digest).to eq(session[:oidc][:state_digest])
    end

    context 'Client configured with AAL 2-phishing-resistant' do
      let(:aal) { '2-phishing-resistant' }
      it 'returns an auth URL with AAL 2-phishing-resistant' do
        auth_uri = URI.parse(subject.redirect_url)

        expect(auth_uri.hostname).to eq('idp.example.gov')
        expect(auth_uri.path).to eq('/openid_connect/authorize')

        params = Rack::Utils.parse_query(auth_uri.query)

        expect(params['acr_values']).to eq('http://idmanagement.gov/ns/assurance/loa/1 http://idmanagement.gov/ns/assurance/aal/2?phishing_resistant=true')
      end
    end

    context 'Client configured with AAL 2-hspd12' do
      let(:aal) { '2-hspd12' }
      it 'returns an auth URL with AAL 2-hspd12' do
        auth_uri = URI.parse(subject.redirect_url)

        expect(auth_uri.hostname).to eq('idp.example.gov')
        expect(auth_uri.path).to eq('/openid_connect/authorize')

        params = Rack::Utils.parse_query(auth_uri.query)

        expect(params['acr_values']).to eq('http://idmanagement.gov/ns/assurance/loa/1 http://idmanagement.gov/ns/assurance/aal/2?hspd12=true')
      end
    end

    context 'Client configured with AAL 3-hspd12' do
      let(:aal) { '3-hspd12' }
      it 'returns an auth URL with AAL 3-hspd12' do
        auth_uri = URI.parse(subject.redirect_url)

        expect(auth_uri.hostname).to eq('idp.example.gov')
        expect(auth_uri.path).to eq('/openid_connect/authorize')

        params = Rack::Utils.parse_query(auth_uri.query)

        expect(params['acr_values']).to eq('http://idmanagement.gov/ns/assurance/loa/1 http://idmanagement.gov/ns/assurance/aal/3?hspd12=true')
      end
    end
  end
end
