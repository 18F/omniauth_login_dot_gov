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
      :phone_verified
    ) do

      def initialize(
        uuid: nil,
        email: nil,
        email_verified: nil,
        family_name: nil,
        given_name: nil,
        birthdate: nil,
        social_security_number: nil,
        address: nil,
        phone: nil,
        phone_verified: nil
      )
        self.uuid = uuid
        self.email = email
        self.email_verified = email_verified
        self.family_name = family_name
        self.given_name = given_name
        self.birthdate = birthdate
        self.social_security_number = social_security_number
        self.address = address
        self.phone = phone
        self.phone_verified = phone_verified
      end

      def to_h
        super().merge(name: email || uuid)
      end
    end
  end
end
