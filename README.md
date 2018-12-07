This gem can be used with OmniAuth to provide authentication with Login.gov in
a rack application.

# Getting started in a Rails app

This describes the configuration for a rails app identified by `myapp` that runs
on port `4040`. You should be able to change the configuration as necessary for
your application.

First you will need a private key and a certificate for that private key.
Those can be generated with the following:

```shell
openssl req -nodes -newkey rsa:2048 -x509 -keyout myapp.pem -out myapp.crt
```

Copy the certificate to `/config/certs/sp/myapp.crt` in the
[identity-idp](https://github.com/18F/identity-idp). Then, add the following
entry to `config/service_providers.yml`:

```yaml
'urn:gov:gsa:openidconnect:sp:myapp':
  agency: 'GSA'
  cert: 'myapp'
  friendly_name: 'Demo OmniAuth app'
  logo: '18f.svg'
  redirect_uris:
    - 'http://localhost:4040/auth/logindotgov/callback'
```

Run `rake db:seed` to update the service provider table.

Now, the key can be added to your repo. For this example let's put it at
`config/myapp.pem`.

Add this gem to the Gemfile and run `bundle install`:

```ruby
gem 'omniauth_login_dot_gov', :git => 'https://github.com/18f/omniauth_login_dot_gov.git'
```

Now, configure the omniauth middleware and add it in an initializer:

```ruby
# config/initializers/omniauth.rb
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :login_dot_gov, {
    client_id: 'urn:gov:gsa:openidconnect:sp:myapp',
    idp_base_url: 'http://localhost:3000/',
    ial: 1,
    private_key: OpenSSL::PKey::RSA.new(File.read('config/myapp.pem')),
    redirect_uri: 'http://localhost:4040/auth/logindotgov/callback',
  }
end
```

Now start both apps and visit `/auth/logindotgov` on `myapp`.
