require 'rails_helper'

RSpec.describe EncodeService do
  describe '.call' do
    context 'with valid HTTPS URL' do
      let(:original_url) { 'https://example.com/path/123456' }

      it 'creates a new ShortUrl' do
        result = described_class.call(original_url: original_url)

        expect(result).to be_persisted
        expect(result.original_url).to eq(original_url)
        expect(result.short_code).to be_present
      end
    end

    context 'with duplicate URL' do
      let(:original_url) { 'https://example.com/duplicate' }

      before do
        ShortUrl.create!(original_url: original_url)
      end

      it 'returns existing ShortUrl' do
        expect {
          described_class.call(original_url: original_url)
        }.not_to change(ShortUrl, :count)
      end

      it 'returns the same short code' do
        existing = ShortUrl.find_by(original_url: original_url)
        result = described_class.call(original_url: original_url)

        expect(result.short_code).to eq(existing.short_code)
      end
    end

    context 'with invalid URL' do
      it 'raises InvalidLinkError for non-HTTP URL' do
        expect {
          described_class.call(original_url: 'ftp://example.com')
        }.to raise_error(Api::Errors::InvalidLinkError, 'Your link is invalid. Please check it again')
      end

      it 'raises InvalidLinkError for empty string' do
        expect {
          described_class.call(original_url: '')
        }.to raise_error(Api::Errors::InvalidLinkError)
      end

      it 'raises InvalidLinkError for nil' do
        expect {
          described_class.call(original_url: nil)
        }.to raise_error(Api::Errors::InvalidLinkError)
      end
    end

    context 'with URL containing special characters' do
      it 'handles URLs with query parameters' do
        url = 'https://example.com/search?q=test&page=1'
        result = described_class.call(original_url: url)

        expect(result.original_url).to eq(url)
      end

      it 'handles URLs with encoded characters' do
        url = 'https://example.com/path%20with%20spaces'
        result = described_class.call(original_url: url)

        expect(result.original_url).to eq(url)
      end
    end
  end
end
