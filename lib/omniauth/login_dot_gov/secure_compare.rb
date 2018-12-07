module OmniAuth
  module LoginDotGov
    class SecureCompare
      # Borrowed from Devise.secure_compare
      # Ref: https://github.com/plataformatec/devise/blob/cb663e96a370ba5d3dc6aa8ea3a2683268e980a0/lib/devise.rb#L500-L507
      def self.compare(a, b)
        return false if a.nil? || b.nil? || a.empty? || b.empty? || a.bytesize != b.bytesize
        l = a.unpack "C#{a.bytesize}"

        res = 0
        b.each_byte { |byte| res |= byte ^ l.shift }
        res == 0
      end
    end
  end
end
