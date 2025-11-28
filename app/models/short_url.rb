class ShortUrl < ApplicationRecord
  CODE_LENGTH = ENV.fetch('SHORT_CODE_LENGTH', 8).to_i

  validates :original_url, presence: true, uniqueness: true
  validates :short_code, presence: true

  before_validation :populate_short_code, on: :create

  def full_short_url
    base_domain = ENV.fetch('BASE_DOMAIN', 'http://localhost:3000')
    "#{base_domain}/#{short_code}"
  end

  private

  def populate_short_code
    self.short_code = SecureRandom.alphanumeric(CODE_LENGTH)
  end
end
