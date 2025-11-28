# Setup and Run Instructions

## Prerequisites

- Ruby 3.1.2
- PostgreSQL 12+
- Bundler

## Installation

### 1. Clone the repository

```bash
git clone git@github.com:ThanhTuan2191/short-url.git
cd short-url
```

### 2. Install dependencies

```bash
bundle install
```

### 3. Setup database

```bash
# Create databases
bin/rails db:create

# Run migrations
bin/rails db:migrate

# For test database
RAILS_ENV=test bin/rails db:migrate
```

### 4. Environment variables (optional)

Create a `.env` file or export these variables:

```bash
# default: http://localhost:3000
export BASE_DOMAIN=https://your-domain.com

# Custom short code length
export SHORT_CODE_LENGTH=8
```

## Running the Application

### Start the server

```bash
rails s
```

The API will be available at `http://localhost:3000`

## Running Tests

### Run all tests

```bash
bundle exec rspec
```

## API Endpoints

### Encode (Shorten URL)

**Request:**
```bash
curl -X POST http://localhost:3000/api/v1/encode \
  -H "Content-Type: application/json" \
  -d '{"short_url": {"original_url": "https://example.com/very/long/url"}}'
```

**Response:**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "short_url": "http://localhost:3000/aB3xY9kL",
    "original_url": "https://example.com/very/long/url",
    "short_code": "aB3xY9kL"
  }
}
```

### Decode (Expand URL)

**Request:**
```bash
curl -X POST http://localhost:3000/api/v1/decode \
  -H "Content-Type: application/json" \
  -d '{"short_url": {"full_short_url": "http://localhost:3000/aB3xY9kL"}}'
```

Or with just the short code:
```bash
curl -X POST http://localhost:3000/api/v1/decode \
  -H "Content-Type: application/json" \
  -d '{"short_url": {"full_short_url": "aB3xY9kL"}}'
```

**Response:**
```json
{
  "success": true,
  "message": "Success",
  "data": {
    "short_url": "http://localhost:3000/aB3xY9kL",
    "original_url": "https://example.com/very/long/url",
    "short_code": "aB3xY9kL"
  }
}
```

## Error Responses

### Invalid URL (422 Unprocessable Entity)
```json
{
  "success": false,
  "message": "Your link is invalid. Please check it again"
}
```

### Invalid Short URL Format (422 Unprocessable Entity)
```json
{
  "success": false,
  "message": "Invalid short URL format"
}
```

### Short Code Not Found (404 Not Found)
```json
{
  "success": false,
  "message": "Couldn't find ShortUrl"
}
```