# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'openssl'
require 'json'
require 'jsonclient'

module ALGOSEC_SDK
  # Adds the ability for httpclient to set proper content-type for Hash AND Array body
  class AdvancedJSONClient < JSONClient
    def argument_to_hash_for_json(args)
      hash = argument_to_hash(args, :body, :header, :follow_redirect)
      if hash[:body].is_a?(Hash) || hash[:body].is_a?(Array)
        hash[:header] = json_header(hash[:header])
        hash[:body] = JSON.generate(hash[:body])
      end
      hash
    end
  end
end

module ALGOSEC_SDK
  # Contains all the methods for making API REST calls
  module Rest
    def init_http_client
      @http_client = ALGOSEC_SDK::AdvancedJSONClient.new(force_basic_auth: true)
      @http_client.proxy = nil if @disable_proxy
      @http_client.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE unless @ssl_enabled
      @http_client.set_auth(@host, @user, @password)
    end

    # Make a restful API request to the AlgoSec
    # @param [Symbol] type the rest method/type Options are :get, :post, :put, :patch, and :delete
    # @param [String] path the path for the request. Usually starts with "/rest/"
    # @param [Hash] options the options for the request
    # @option options [String] :body Hash to be converted into json and set as the request body
    # @option options [String] :Content-Type ('application/json') Set to nil or :none to have this option removed
    # @raise [InvalidRequest] if the request is invalid
    # @raise [SocketError] if a connection could not be made
    # @raise [OpenSSL::SSL::SSLError] if SSL validation of the AlgoSec's certificate failed
    # @return [NetHTTPResponse] The response object
    def rest_api(type, path, options = {})
      raise InvalidRequest, 'Must specify path' unless path
      raise InvalidRequest, 'Must specify type' unless type
      @logger.debug "Making :#{type} rest call to #{@host}#{path}"

      uri = "#{@host}#{path}"
      response = send_request(type, uri, options)
      @logger.debug "  Response: Code=#{response.status}. Headers=#{response.headers}\n  Body=#{response.body}"
      response
    rescue OpenSSL::SSL::SSLError => e
      msg = 'SSL verification failed for the request. Please either:'
      msg += "\n  1. Install the necessary certificate(s) into your cert store"
      msg += ". Using cert store: #{ENV['SSL_CERT_FILE']}" if ENV['SSL_CERT_FILE']
      msg += "\n  2. Set the :ssl_enabled option to false for your AlgoSec client (not recommended)"
      @logger.error msg
      raise e
    rescue SocketError => e
      msg = "Failed to connect to AlgoSec host #{@host}!\n"
      @logger.error msg
      raise e
    end

    # Make a restful GET request
    # Parameters & return value align with those of the {ALGOSEC_SDK::Rest::rest_api} method above
    def rest_get(path, options = {})
      rest_api(:get, path, options)
    end

    # Make a restful POST request
    # Parameters & return value align with those of the {ALGOSEC_SDK::Rest::rest_api} method above
    def rest_post(path, options = {})
      rest_api(:post, path, options)
    end

    # Make a restful PUT request
    # Parameters & return value align with those of the {ALGOSEC_SDK::Rest::rest_api} method above
    def rest_put(path, options = {})
      rest_api(:put, path, options)
    end

    # Make a restful PATCH request
    # Parameters & return value align with those of the {ALGOSEC_SDK::Rest::rest_api} method above
    def rest_patch(path, options = {})
      rest_api(:patch, path, options)
    end

    # Make a restful DELETE request
    # Parameters & return value align with those of the {ALGOSEC_SDK::Rest::rest_api} method above
    def rest_delete(path, options = {})
      rest_api(:delete, path, options)
    end

    RESPONSE_CODE_OK           = 200
    RESPONSE_CODE_CREATED      = 201
    RESPONSE_CODE_ACCEPTED     = 202
    RESPONSE_CODE_NO_CONTENT   = 204
    RESPONSE_CODE_BAD_REQUEST  = 400
    RESPONSE_CODE_UNAUTHORIZED = 401
    RESPONSE_CODE_NOT_FOUND    = 404

    # Handle the response for rest call.
    #   If an asynchronous task was started, this waits for it to complete.
    # @param [HTTPResponse] response
    # @raise [ALGOSEC_SDK::BadRequest] if the request failed with a 400 status
    # @raise [ALGOSEC_SDK::Unauthorized] if the request failed with a 401 status
    # @raise [ALGOSEC_SDK::NotFound] if the request failed with a 404 status
    # @raise [ALGOSEC_SDK::RequestError] if the request failed with any other status
    # @return [Hash] The parsed JSON body
    def response_handler(response)
      case response.status
      when RESPONSE_CODE_OK # Synchronous read/query
        response.body
      when RESPONSE_CODE_CREATED # Synchronous add
        response.body
        # when RESPONSE_CODE_ACCEPTED # Asynchronous add, update or delete
        # return response.body #
        # @logger.debug "Waiting for task: #{response.headers['location']}"
        # task = wait_for(response.headers['location'])
        # return true unless task['associatedResource'] && task['associatedResource']['resourceUri']
        # resource_data = rest_get(task['associatedResource']['resourceUri'])
        # return JSON.parse(resource_data.body)
      when RESPONSE_CODE_NO_CONTENT # Synchronous delete
        {}
      when RESPONSE_CODE_BAD_REQUEST
        raise BadRequest, "400 BAD REQUEST #{response.body}"
      when RESPONSE_CODE_UNAUTHORIZED
        raise Unauthorized, "401 UNAUTHORIZED #{response.body}"
      when RESPONSE_CODE_NOT_FOUND
        raise NotFound, "404 NOT FOUND #{response.body}"
      else
        raise RequestError, "#{response.status} #{response.body}"
      end
    end

    private

    # @param type [Symbol] The type of request object to build (get, post, put, patch, or delete)
    # @param uri [String] full URI string
    # @param options [Hash] Options for building the request. All options except "body" are set as headers.
    # @raise [ALGOSEC_SDK::InvalidRequest] if the request type is not recognized
    def send_request(type, uri, options)
      case type.downcase
      when 'get', :get
        response = @http_client.get(uri, options)
      when 'post', :post
        response = @http_client.post(uri, options)
      when 'put', :put
        response = @http_client.put(uri, options)
      when 'patch', :patch
        response = @http_client.patch(uri, options)
      when 'delete', :delete
        response = @http_client.delete(uri, options)
      else
        raise InvalidRequest, "Invalid rest method: #{type}. Valid methods are: get, post, put, patch, delete"
      end
      response
    end
  end
end
