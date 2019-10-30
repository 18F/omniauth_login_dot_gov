# login.gov Omniauth strategy

This gem is an Omniauth strategy to provide authentication with Login.gov in a rack application with the OpenID:Connect protocol.

#### ⚠️  Common Vulnerabilities and Exposure Warning:
There is a known vulnerability with Omniauth that affects this gem as
well as any implementation of Omniauth with a single strategy. Please
review [CVE-2015-9284](https://nvd.nist.gov/vuln/detail/CVE-2015-9284) for more
information and mitigation steps.

## Getting started in a Rails app

Our [developer documentation](https://developers.login.gov/oidc/) will have the most up-to-date information on OIDC integration including available scopes and attributes.

#### Generate your keys

Before you begin, you will need a self-signed private and public certificate/key pair.
To generate the private and public key pair and output your public certificate with PEM formatting:

```shell
openssl req -nodes -x509 -days 365 -newkey rsa:2048 -keyout private.pem -out public.crt
```

Note: the `-nodes` flag skips encryption of the private key and is not recommended for production use.

#### Register your app with the login.gov sandbox

You will need to register your service provider with our sandbox environment using the login.gov [Partner Dashboard](https://dashboard.int.identitysandbox.gov). Note: this is not your production login.gov account.

1. Log in to the [Partner Dashboard](https://dashboard.int.identitysandbox.gov).
2. Choose [Create new test app](https://dashboard.int.identitysandbox.gov/service_providers/new).
3. Enter the required fields to identify your service provider, including the **public** self-signed certificate you generated earlier.

#### Configure your app

Now that your app is configured with login.gov's sandbox as a Service Provider, you can begin configuring your local application.

1. Copy your private key to your application's `config` directory (eg. `config/private.pem`)
2. Add this gem to the Gemfile:
  ```ruby
  gem 'omniauth_login_dot_gov', :git => 'https://github.com/18f/omniauth_login_dot_gov.git'
  ```
3. Install this gem and dependencies with `bundle install`
4. Now, configure the Omniauth middleware with an initializer:
  ```ruby
  # config/initializers/omniauth.rb
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :login_dot_gov, {
      name: :login_dot_gov,
      client_id: 'urn:gov:gsa:openidconnect:sp:myapp', # same value as registered in the Partner Dashboard
      idp_base_url: 'https://idp.int.identitysandbox.gov/', # login.gov sandbox environment IdP
      ial: 1,
      private_key: OpenSSL::PKey::RSA.new(File.read('config/private.pem')),
      redirect_uri: 'http://localhost:3000/auth/logindotgov/callback',
    }
  end
  ```
5. Create a controller for handling the callback, such as this:
  ```ruby
  # app/controllers/users/omniauth_controller.rb
  module Users
    class OmniauthController < ApplicationController
      def callback
        omniauth_info = request.env['omniauth.auth']['info']
        @user = User.find_by(email: omniauth_info['email'])
        if @user
          @user.update!(uuid: omniauth_info['uuid'])
          sign_in @user
          redirect_to service_providers_path

        # Can't find an account, tell user to contact login.gov team
        else
          redirect_to users_none_url
        end
      end
    end
  end
  ```
6. Add the callback route to `routes.rb`
  ```ruby
  get '/auth/logindotgov/callback' => 'users/omniauth#callback'
  ```

7. Start your application and visit: `/auth/logindotgov` (eg. http://localhost:3000/auth/logindotgov) to initiate authentication with login.gov!


## Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0
> dedication. By submitting a pull request, you are agreeing to comply
> with this waiver of copyright interest.