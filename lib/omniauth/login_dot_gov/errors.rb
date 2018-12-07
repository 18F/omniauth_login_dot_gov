module OmniAuth
  module LoginDotGov
    class Error < StandardError
      def key
        self.class.name.demodulize.underscore.gsub(/_error$/, '').to_sym
      end
    end

    class OpenidDiscoveryError < Error
    end

    class CallbackStateMismatchError < Error
    end

    class CallbackAccessDeniedError < Error
    end

    class CallbackInvalidRequestError < Error
    end

    class IdTokenRequestError < Error
    end

    class IdTokenNonceMismatchError < Error
    end

    class UserinfoRequestError < Error
    end
  end
end
