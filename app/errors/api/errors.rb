module Api
  module Errors
    class BaseError < StandardError
      attr_reader :message
      def initialize(message)
        @message = message
      end
    end

    class InvalidLinkError < BaseError; end
  end
end
