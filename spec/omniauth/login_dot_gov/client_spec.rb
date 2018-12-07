describe OmniAuth::LoginDotGov::Client do
  it 'initializes' do
    idp_configuration = MockIdpConfiguration.new
    allow(OmniAuth::LoginDotGov::IdpConfiguration).to receive(:new).
      with(idp_base_url: IdpFixtures.base_url).
      and_return(idp_configuration)

    subject = described_class.new(
      client_id: ClientFixtures.client_id,
      ial: 1,
      idp_base_url: IdpFixtures.base_url,
      private_key: ClientFixtures.private_key,
      redirect_uri: ClientFixtures.redirect_uri,
      scope: 'email openid'
    )

    expect(subject.client_id).to eq(ClientFixtures.client_id)
    expect(subject.ial).to eq(1)
    expect(subject.idp_configuration).to eq(idp_configuration)
    expect(subject.private_key).to eq(ClientFixtures.private_key)
    expect(subject.redirect_uri).to eq(ClientFixtures.redirect_uri)
    expect(subject.scope).to eq('email openid')
  end
end
