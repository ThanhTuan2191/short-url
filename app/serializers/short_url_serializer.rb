class ShortUrlSerializer
  attr_reader :short_url

  def initialize(short_url)
    @short_url = short_url
  end

  def as_json
    {
      short_url: short_url.full_short_url,
      original_url: short_url.original_url,
      short_code: short_url.short_code
    }
  end
end
