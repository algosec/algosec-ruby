# frozen_string_literal: true

require_relative './../spec_helper'

RSpec.describe ALGOSEC_SDK::Client do
  include_context 'shared context'

  let(:path) { '/fake' }
  let(:data) { { 'name' => 'Fake', 'description' => 'Fake Resource', 'uri' => path } }

  describe '#init_http_client' do
    before :each do
      fake_response = FakeResponse.new({ name: 'New' }, 200, location: path)
      allow(@client.http_client).to receive(:request).and_return(fake_response)
    end

    it 'respects the disable_proxy client option' do
      @client.disable_proxy = true
      @client.http_client.proxy = 'http://someproxy.com'
      expect { @client.init_http_client }.to change { @client.http_client.proxy }.from(anything).to(nil)
    end

    it 'does not disable the proxy if disable_proxy client option is set to false' do
      @client.disable_proxy = false
      expect { @client.init_http_client }.to_not change { @client.http_client.proxy }
    end

    it 'does not change ssl config if ssl_enabled is true' do
      @client.ssl_enabled = true
      expect { @client.init_http_client }.to_not change { @client.http_client.ssl_config.verify_mode }
    end

    it 'disable the ssl verification if the ssl_enabled client option is set to false' do
      @client.ssl_enabled = false
      expect { @client.init_http_client }.to change { @client.http_client.ssl_config.verify_mode }.to(
        OpenSSL::SSL::VERIFY_NONE
      )
    end

    it 'initiate the httpclient and set the basic auth' do
      an_instance = instance_double(ALGOSEC_SDK::AdvancedJSONClient)
      allow(ALGOSEC_SDK::AdvancedJSONClient).to receive(:new).and_return(an_instance)
      expect(ALGOSEC_SDK::AdvancedJSONClient).to receive(:new).with(force_basic_auth: true)
      expect(an_instance).to receive(:set_auth).with(
        'https://algosec.example.com',
        'admin',
        'secret123'
      )
      @client.init_http_client
    end
  end

  describe '#rest_api' do
    before :each do
      fake_response = FakeResponse.new({ name: 'New' }, 200, location: path)
      allow(@client.http_client).to receive(:request).and_return(fake_response)
    end

    it 'requires a path' do
      expect { @client.rest_api(:get, nil) }.to raise_error(ALGOSEC_SDK::InvalidRequest, /Must specify path/)
    end

    it 'logs the request type and path (debug level)' do
      @client.logger.level = @client.logger.class.const_get('DEBUG')
      %w[get post put patch delete].each do |type|
        expect { @client.rest_api(type, path) }
          .to output(/Making :#{type} rest call to #{@client.host + path}/).to_stdout_from_any_process
      end
    end

    it 'raises an error when the ssl validation fails' do
      allow_any_instance_of(ALGOSEC_SDK::AdvancedJSONClient).to receive(:request).and_raise(
        OpenSSL::SSL::SSLError, 'Msg'
      )
      expect(@client.logger).to receive(:error).with(/SSL verification failed/)
      expect { @client.rest_api(:get, path) }.to raise_error(OpenSSL::SSL::SSLError)
    end

    it 'raises an error when the socket connection fails' do
      allow_any_instance_of(ALGOSEC_SDK::AdvancedJSONClient).to receive(:request).and_raise(SocketError, 'Msg')
      expect(@client.logger).to receive(:error).with(/Failed to connect to AlgoSec host/)
      expect { @client.rest_api(:get, path) }.to raise_error(SocketError)
    end
  end

  describe '#rest_get' do
    it 'calls rest_api' do
      expect(@client).to receive(:rest_api).with(:get, path, {})
      @client.rest_get(path)
    end
  end

  describe '#rest_post' do
    it 'calls rest_api' do
      expect(@client).to receive(:rest_api).with(:post, path, body: data)
      @client.rest_post(path, body: data)
    end

    it 'has default options and api_ver' do
      expect(@client).to receive(:rest_api).with(:post, path, {})
      @client.rest_post(path)
    end
  end

  describe '#rest_put' do
    it 'calls rest_api' do
      expect(@client).to receive(:rest_api).with(:put, path, {})
      @client.rest_put(path, {})
    end

    it 'has default options and api_ver' do
      expect(@client).to receive(:rest_api).with(:put, path, {})
      @client.rest_put(path)
    end
  end

  describe '#rest_patch' do
    it 'calls rest_api' do
      expect(@client).to receive(:rest_api).with(:patch, path, {})
      @client.rest_patch(path, {})
    end

    it 'has default options and api_ver' do
      expect(@client).to receive(:rest_api).with(:patch, path, {})
      @client.rest_patch(path)
    end
  end

  describe '#rest_delete' do
    it 'calls rest_api' do
      expect(@client).to receive(:rest_api).with(:delete, path, {})
      @client.rest_delete(path, {})
    end

    it 'has default options and api_ver' do
      expect(@client).to receive(:rest_api).with(:delete, path, {})
      @client.rest_delete(path)
    end
  end

  describe '#response_handler' do
    it 'returns the JSON-parsed body for 200 status' do
      expect(@client.response_handler(FakeResponse.new(data))).to eq(data)
    end

    it 'returns the JSON-parsed body for 201 status' do
      expect(@client.response_handler(FakeResponse.new(data, 201))).to eq(data)
    end

    it 'returns an empty hash for 204 status' do
      expect(@client.response_handler(FakeResponse.new({}, 204))).to eq({})
    end

    it 'raises an error for 400 status' do
      resp = FakeResponse.new({ message: 'Blah' }, 400)
      expect { @client.response_handler(resp) }.to raise_error(ALGOSEC_SDK::BadRequest, /400 BAD REQUEST.*Blah/)
    end

    it 'raises an error for 401 status' do
      resp = FakeResponse.new({ message: 'Blah' }, 401)
      expect { @client.response_handler(resp) }.to raise_error(ALGOSEC_SDK::Unauthorized, /401 UNAUTHORIZED.*Blah/)
    end

    it 'raises an error for 404 status' do
      resp = FakeResponse.new({ message: 'Blah' }, 404)
      expect { @client.response_handler(resp) }.to raise_error(ALGOSEC_SDK::NotFound, /404 NOT FOUND.*Blah/)
    end

    it 'raises an error for undefined status codes' do
      [0, 19, 199, 203, 399, 402, 500].each do |status|
        resp = FakeResponse.new({ message: 'Blah' }, status)
        expect { @client.response_handler(resp) }.to raise_error(ALGOSEC_SDK::RequestError, /#{status}.*Blah/)
      end
    end
  end

  describe '#send_request' do
    before :each do
      @uri = URI.parse(CGI.escape(@client.host + path))
      fake_response = FakeResponse.new({ name: 'New' }, 200, location: path)
      allow_any_instance_of(ALGOSEC_SDK::AdvancedJSONClient).to receive(:request).and_return(fake_response)
    end

    it 'fails when an invalid request type is given' do
      expect { @client.send(:send_request, :fake, @uri, {}) }.to raise_error(/Invalid rest method/)
    end
  end
end
