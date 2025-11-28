module Api
  module V1
    class UrlsController < ApplicationController
      def encode
        short_url = EncodeService.call(**encode_params)
        render_success ShortUrlSerializer.new(short_url).as_json
      end

      def decode
        short_url = DecodeService.call(**decode_params)
        render_success ShortUrlSerializer.new(short_url).as_json
      end

      private

      def encode_params
        params.require(:short_url).permit(:original_url)
      end

      def decode_params
        params.require(:short_url).permit(:full_short_url)
      end
    end
  end
end
