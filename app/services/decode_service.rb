class DecodeService < BaseService
  def call
    validate!
    find_short_url
  end

  private

  def validate!
    raise Api::Errors::InvalidLinkError.new('Short URL is required') if short_url_param.blank?
    raise Api::Errors::InvalidLinkError.new('Invalid short URL format') unless valid_format?
  end

  def valid_format?
    return false unless short_code.match?(/\A[a-zA-Z0-9]+\z/)

    uri = URI.parse(short_url_param)
    base_uri = URI.parse(base_domain)
    uri.host == base_uri.host
  rescue URI::InvalidURIError
    false
  end

  def find_short_url
    ShortUrl.find_by!(short_code: short_code)
  end

  def short_code
    short_url_param.split('/').last
  end

  def short_url_param
    params[:full_short_url]
  end

  def base_domain
    ENV.fetch('BASE_DOMAIN', 'http://localhost:3000')
  end
end
