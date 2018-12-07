module OmniAuth
  module LoginDotGov
    Userinfo = Struct.new(
      :uuid,
      :email,
      :email_verified,
      :family_name,
      :given_name,
      :birthdate,
      :social_security_number,
      :address,
      :phone,
      :phone_verified,
      keyword_init: true
    ) do
      def to_h
        super().merge(name: email || uuid)
      end
    end
  end
end
