# Short URL Service

A URL shortening API built with Ruby on Rails. Converts long URLs into short, shareable codes and decodes them back to the original URLs.

## Security

### Potential Attack Vectors

#### 1. URL Validation Bypass

**Risk:** Malicious URLs could be shortened and distributed.

**Current Mitigations:**
- Only HTTP/HTTPS URLs are accepted
- Use URI.parse validates URL structure
- Non-HTTP schemes (javascript:, data:, file:) are rejected

**Future Enhancements:**
- Add URL blocklist for known malicious domains
- Add rate limiting per IP/user to prevent mass URL creation

#### 2. Enumeration Attack

**Risk:** Attackers could enumerate short codes to discover all shortened URLs.

**Current Mitigations:**
- Random code generation using SecureRandom.alphanumeric. With 8 characters alphanumeric codes: 62^8 = 218 trillion combinations
- Codes are not sequential or predictable

**Future Enhancements:**
- Implement rate limiting on decode endpoint
- Add CAPTCHA for high-volume requests

#### 3. Denial of Service (DoS)

**Risk:** Attackers could flood the service with requests.

**Current Mitigations:**
- Database unique constraints prevent duplicate URLs
- Input validation rejects invalid URLs early

**Future Enhancements:**
- Implement rate limiting (e.g., 20 requests/minute per IP)

#### 4. SQL Injection

**Risk:** Malicious input could manipulate database queries.

**Current Mitigations:**
- Rails ActiveRecord parameterized queries
- Strong parameters whitelist allowed fields
- No raw SQL in application code

---

## Scaling

### Current Architecture

```
Client ---> Rails API ---> PostgresSQL
```

### Short Code Generation

**Current Implementation:**
- Random generation using `SecureRandom.alphanumeric(CODE_LENGTH)`
- Default length: 8 characters (62^8 = 218 trillion combinations)
- Collision handled via database unique constraint + retry

### Scaling

**Current Implementation:**
- PostgreSQL handles millions of rows efficiently
- Unique indexes on `short_code` and `original_url` ensure fast lookups
- UUID primary keys avoid sequential ID bottlenecks

**Future Enhancements:**
- Add Redis for caching URLs

**Decode:**
```ruby
def find_short_url(short_code)
  Rails.cache.fetch("short_url:#{short_code}", expires_in: 1.hour) do
    ShortUrl.find_by!(short_code: short_code)
  end
end
```

**Encode:**
```ruby
def find_or_create_short_url(original_url)
  Rails.cache.fetch("original:#{Digest::SHA256.hexdigest(original_url)}", expires_in: 1.hour) do
    ShortUrl.find_or_create_by!(original_url: original_url)
  end
end
```

### Monitoring Recommendations

- Track collision rate
