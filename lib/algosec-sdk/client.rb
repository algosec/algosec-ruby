# frozen_string_literal: true

require 'logger'
require_relative 'rest'
# Load all helpers:
Dir[File.join(File.dirname(__FILE__), '/helpers/*.rb')].each { |file| require file }

module ALGOSEC_SDK
  # The client defines the connection to the AlgoSec and handles communication with it
  class Client
    attr_accessor :http_client, :host, :user, :password, :ssl_enabled, :disable_proxy, :logger, :log_level

    # Create a client object
    # @param [Hash] options the options to configure the client
    # @option options [String] :host (ENV['ALGOSEC_HOST']) URL, hostname, or IP address of the AlgoSec server
    # @option options [String] :user ('admin') Username to use for authentication with the AlgoSec server
    # @option options [String] :password Password to use for authentication with the AlgoSec server
    # @option options [Logger] :logger (Logger.new(STDOUT)) Logger object to use.
    #   Must implement debug(String), info(String), warn(String), error(String), & level=
    # @option options [Symbol] :log_level (:info) Log level.
    #   Logger must define a constant with this name. ie Logger::INFO
    # @option options [Boolean] :ssl_enabled (true) Use ssl for requests?
    # @option options [Boolean] :disable_proxy (false) Disable usage of a proxy for requests?
    def initialize(options = {})
      options = Hash[options.map { |k, v| [k.to_sym, v] }] # Convert string hash keys to symbols
      @logger = options[:logger] || Logger.new(STDOUT)
      %i[debug info warn error level=].each do |m|
        raise "Logger must respond to #{m} method " unless @logger.respond_to?(m)
      end
      @log_level = options[:log_level] || :info
      @logger.level = begin
                        @logger.class.const_get(@log_level.upcase)
                      rescue StandardError
                        @log_level
                      end
      @host = options[:host] || ENV['ALGOSEC_HOST']
      raise InvalidClient, 'Must set the host option' unless @host
      @host = 'https://' + @host unless @host.start_with?('http://', 'https://')
      @ssl_enabled = true # Default
      if ENV.key?('ALGOSEC_SSL_ENABLED')
        @ssl_enabled = case ENV['ALGOSEC_SSL_ENABLED']
                       when 'true', '1' then true
                       when 'false', '0' then false
                       else ENV['ALGOSEC_SSL_ENABLED']
                       end
      end
      @ssl_enabled = options[:ssl_enabled] unless options[:ssl_enabled].nil?
      unless [true, false].include?(@ssl_enabled)
        raise InvalidClient, "ssl_enabled option must be true or false. Got '#{@ssl_enabled}'"
      end
      unless @ssl_enabled
        @logger.warn "SSL is disabled for all requests to #{@host}!"\
                               ' We recommend you import the necessary certificates instead of disabling SSL.'
      end
      @disable_proxy = options[:disable_proxy]
      unless [true, false, nil].include?(@disable_proxy)
        raise InvalidClient, 'disable_proxy option must be true, false, or nil'
      end
      @logger.warn 'User option not set. Using default (admin)' unless options[:user] || ENV['ALGOSEC_USER']
      @user = options[:user] || ENV['ALGOSEC_USER'] || 'admin'
      @password = options[:password] || ENV['ALGOSEC_PASSWORD']
      raise InvalidClient, 'Must set the password option' unless @password
      init_http_client
    end

    include Rest

    # Include helper modules:
    include BusinessFlowHelper
  end
end
