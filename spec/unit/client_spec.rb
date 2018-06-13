require_relative './../spec_helper'

RSpec.describe ALGOSEC_SDK::Client do

  describe '#initialize' do
    it 'creates a client with valid credentials' do
      options = { host: 'https://algosec.example.com', user: 'admin', password: 'secret123' }
      client = described_class.new(options)
      expect(client.host).to eq('https://algosec.example.com')
      expect(client.user).to eq('admin')
      expect(client.password).to eq('secret123')
      expect(client.ssl_enabled).to eq(true)
      expect(client.disable_proxy).to eq(nil)
      expect(client.log_level).to eq(:info)
      expect(client.logger).to be_a(Logger)
    end

    it 'requires the host attribute to be set' do
      expect { described_class.new({}) }.to raise_error(ALGOSEC_SDK::InvalidClient, /Must set the host option/)
    end

    it 'automatically prepends the host with "https://"' do
      options = { host: 'algosec.example.com', user: 'admin', password: 'secret123' }
      client = described_class.new(options)
      expect(client.host).to eq('https://algosec.example.com')
    end

    it 'requires the password attribute to be set' do
      options = { host: 'algosec.example.com', user: 'admin' }
      expect { described_class.new(options) }.to raise_error(ALGOSEC_SDK::InvalidClient, /Must set the password/)
    end

    it 'sets the username to "admin" by default' do
      options = { host: 'algosec.example.com', password: 'secret123' }
      client = nil
      expect { client = described_class.new(options) }.to output(/User option not set. Using default/).to_stdout_from_any_process
      expect(client.user).to eq('admin')
    end

    it 'initiate the httpclient client' do
      options = { host: 'algosec.example.com', user: 'admin', password: 'secret123' }
      expect_any_instance_of(described_class).to receive(:init_http_client).with(no_args)
      described_class.new(options)
    end

    it 'allows the ssl_enabled attribute to be set' do
      expect_any_instance_of(Logger).to receive(:warn).with(/SSL is disabled/).and_return(true)
      options = { host: 'algosec.example.com', user: 'admin', password: 'secret123', ssl_enabled: false }
      client = described_class.new(options)
      expect(client.ssl_enabled).to eq(false)
    end

    it 'does not allow invalid ssl_enabled attributes' do
      options = { host: 'algosec.example.com', user: 'admin', password: 'secret123', ssl_enabled: 'bad' }
      expect { described_class.new(options) }.to raise_error(ALGOSEC_SDK::InvalidClient, /must be true or false/)
    end

    it 'allows the disable_proxy attribute to be set' do
      options = { host: 'algosec.example.com', user: 'admin', password: 'secret123', disable_proxy: true }
      client = described_class.new(options)
      expect(client.disable_proxy).to eq(true)
    end

    it 'allows the log level to be set' do
      options = { host: 'algosec.example.com', user: 'admin', password: 'secret123', log_level: :error }
      client = described_class.new(options)
      expect(client.log_level).to eq(:error)
    end

    it 'respects environment variables' do
      ENV['ALGOSEC_HOST'] = 'algosec.example.com'
      ENV['ALGOSEC_USER'] = 'admin'
      ENV['ALGOSEC_PASSWORD'] = 'secret456'
      ENV['ALGOSEC_SSL_ENABLED'] = 'false'
      expect_any_instance_of(Logger).to receive(:warn).with(/SSL is disabled/).and_return(true)
      client = described_class.new
      expect(client.host).to eq('https://algosec.example.com')
      expect(client.user).to eq('admin')
      expect(client.password).to eq('secret456')
      expect(client.ssl_enabled).to eq(false)
      ENV['ALGOSEC_SSL_ENABLED'] = 'true'
      client = described_class.new
      expect(client.ssl_enabled).to eq(true)
    end

    it 'does not allow invalid ssl_enabled attributes set as an environment variable' do
      ENV['ALGOSEC_SSL_ENABLED'] = 'bad'
      options = { host: 'algosec.example.com', user: 'admin', password: 'secret123' }
      expect { described_class.new(options) }.to raise_error(ALGOSEC_SDK::InvalidClient, /must be true or false/)
    end
  end
end
