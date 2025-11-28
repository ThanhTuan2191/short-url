class EncodeService < BaseService
  def call
    validate!
    find_or_create_short_url
  end

  private 

  attr_reader :params

  def validate!
    raise Api::Errors::InvalidLinkError.new('Your link is invalid. Please check it again') unless valid_link?
  end

  def valid_link?
    valid_link = URI.parse(params[:original_url])
    valid_link.is_a?(URI::HTTP) || valid_link.is_a?(URI::HTTPS)
  rescue StandardError
    false
  end

  def find_or_create_short_url
    ShortUrl.find_or_create_by!(original_url: params[:original_url])
  rescue ActiveRecord::RecordNotUnique => e
    retry
  end
end
