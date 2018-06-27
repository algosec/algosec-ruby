require_relative 'algosec-sdk/version'
require_relative 'algosec-sdk/client'
require_relative 'algosec-sdk/exceptions'

# Module for interracting with the AlgoSec API
module ALGOSEC_SDK
  ENV_VARS = %w[ALGOSEC_HOST ALGOSEC_USER ALGOSEC_PASSWORD ALGOSEC_SSL_ENABLED].freeze
end
