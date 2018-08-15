# frozen_string_literal: true

require 'json'

# Helper for mocking responses
class FakeResponse
  attr_reader :body, :status, :headers

  def initialize(body = {}, status = 200, headers = {})
    @body = body
    @body = @body
    @status = status
    @headers = headers
  end

  def[](key)
    headers[key]
  end
end
