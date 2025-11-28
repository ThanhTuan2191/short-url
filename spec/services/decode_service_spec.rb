require 'rails_helper'

RSpec.describe DecodeService do
  describe '.call' do
    let!(:short_url) { ShortUrl.create!(original_url: 'https://example.com/original') }

    context 'with valid full short URL' do
      it 'returns the ShortUrl record' do
        result = described_class.call(full_short_url: short_url.full_short_url)

        expect(result).to eq(short_url)
      end

      it 'extracts short code from URL path' do
        full_url = "http://localhost:3000/#{short_url.short_code}"
        result = described_class.call(full_short_url: full_url)

        expect(result).to eq(short_url)
      end
    end

    context 'with invalid input' do
      it 'raises not found if the short code is not existed' do
        expect {
          described_class.call(full_short_url: 'http://localhost:3000/notfound')
        }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'raises InvalidLinkError for blank input' do
        expect {
          described_class.call(full_short_url: '')
        }.to raise_error(Api::Errors::InvalidLinkError, 'Short URL is required')
      end

      it 'raises InvalidLinkError for nil input' do
        expect {
          described_class.call(full_short_url: nil)
        }.to raise_error(Api::Errors::InvalidLinkError, 'Short URL is required')
      end

      it 'raises InvalidLinkError for wrong domain' do
        expect {
          described_class.call(full_short_url: "http://invalid.com/#{short_url.short_code}")
        }.to raise_error(Api::Errors::InvalidLinkError, 'Invalid short URL format')
      end
    end
  end
end
