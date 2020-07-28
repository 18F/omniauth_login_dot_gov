describe OmniAuth::LoginDotGov::LogoutUtility do
  include OpenidConfigurationWebmock
  let(:post_logout_redirect_uri) { 'http://localhost:30001' }
  let(:state) { '0123456789098765432101' }
  let(:id_token) { 'abc123' }

  subject do
    described_class.new(
      idp_base_url: IdpFixtures.base_url
    )
  end

  describe 'build_request' do
    before { stub_openid_configuration_request }
    it 'generates state if not given' do
      request = subject.build_request(id_token: id_token, post_logout_redirect_uri: post_logout_redirect_uri)
      state = request.state

      expect(state).to_not be_nil
      expect(state.length).to be >= 22
    end

    it 'generates redirect_uri' do
      request = subject.build_request(id_token: id_token, post_logout_redirect_uri: post_logout_redirect_uri, state: state)
      redirect_uri = request.redirect_uri

      expect(redirect_uri).to start_with(IdpFixtures.base_url)
      expect(redirect_uri).to include(id_token)
      expect(redirect_uri).to include(CGI.escape(post_logout_redirect_uri))
      expect(redirect_uri).to include(state)
    end

    it 'raises with all nil parameters' do
      expect { OmniAuth::LoginDotGov::LogoutUtility.new }.to raise_error(ArgumentError)
    end
  end
end
