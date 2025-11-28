require 'rails_helper'

RSpec.describe Api::V1::UrlsController, type: :request do
  describe 'POST /api/v1/encode' do
    let(:valid_url) { 'https://example.com/long/path' }
    let(:valid_params) { { short_url: { original_url: valid_url } } }

    context 'with valid URL' do
      it 'returns short URL data' do
        post '/api/v1/encode', params: valid_params

        expect(response).to have_http_status(:ok)
        expect(json_response['success']).to be true
        expect(json_response['data']).to include(
          'original_url' => valid_url,
          'short_code' => be_present,
          'short_url' => be_present
        )
      end

      it 'creates a new ShortUrl record' do
        expect {
          post '/api/v1/encode', params: valid_params
        }.to change(ShortUrl, :count).by(1)
      end

      it 'returns existing record for duplicate URL' do
        short_url = ShortUrl.create!(original_url: valid_url)
        short_code = short_url.short_code
        
        post '/api/v1/encode', params: valid_params
        expect(json_response['data']['short_code']).to eq(short_code)
      end
    end

    context 'with invalid URL' do
      it 'returns error for non-HTTP URL' do
        post '/api/v1/encode', params: { short_url: { original_url: 'ftp://example.com' } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['success']).to be false
      end

      it 'returns error for malformed URL' do
        post '/api/v1/encode', params: { short_url: { original_url: 'invalid' } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['success']).to be false
      end

      it 'returns error for blank URL' do
        post '/api/v1/encode', params: { short_url: { original_url: '' } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['success']).to be false
      end
    end
  end

  describe 'POST /api/v1/decode' do
    let!(:short_url) { ShortUrl.create!(original_url: 'https://example.com') }

    context 'with valid short code' do
      it 'returns original URL data' do
        post '/api/v1/decode', params: { short_url: { full_short_url: short_url.full_short_url } }

        expect(response).to have_http_status(:ok)
        expect(json_response['success']).to be true
        expect(json_response['data']).to include(
          'original_url' => short_url.original_url,
          'short_code' => short_url.short_code
        )
      end
    end

    context 'with invalid input' do
      it 'returns error for non-existent short code' do
        post '/api/v1/decode', params: { short_url: { full_short_url: 'nonexistent' } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['success']).to be false
      end

      it 'returns error for wrong domain' do
        post '/api/v1/decode', params: { short_url: { full_short_url: "http://invalid.com/#{short_url.short_code}" } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['success']).to be false
        expect(json_response['message']).to eq('Invalid short URL format')
      end

      it 'returns error for blank input' do
        post '/api/v1/decode', params: { short_url: { full_short_url: '' } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['success']).to be false
      end
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
