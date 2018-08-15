# frozen_string_literal: true

# General context for unit testing:
RSpec.shared_context 'shared context', a: :b do
  before :each do
    options = { host: 'algosec.example.com', user: 'admin', password: 'secret123' }
    @client = ALGOSEC_SDK::Client.new(options)
  end
end
