desc 'Test API SDK end-to-end against an AlgoSec machine'
task :e2e, [:app, :host, :user, :password] => [] do |_t, args|
  require 'algosec-sdk'
  args.with_defaults(
    app: 'TEST',
    host: 'local.algosec.com',
    user: 'admin',
    password: 'algosec'
  )
  options = {
    host: args.host,
    user: args.user,
    password: args.password,
    ssl_enabled: false
  }
  client = ALGOSEC_SDK::Client.new(options)
  client.login

  NEW_FLOW_NAME = 'test-flow-name'.freeze
  NETWORK_OBJECT_IP = '192.168.123.124'.freeze
  NETWORK_SERVICE_NAME = 'TCP/202'.freeze
  NETWORK_SERVICE_DEFINITION = [%w(tcp 202)].freeze

  puts '### END-TO-END INTEGRATION STARTED ###'

  puts "Fetching latest application revision id for: #{args.app}"
  app_revision_id = client.get_app_revision_id_by_name(args.app)
  puts "Application Revision ID Fetched: #{app_revision_id}"

  puts 'Fetching current application flows'
  flows = client.get_application_flows(app_revision_id)
  puts "#{flows.length} flows fetched"

  puts 'Creating application flow'
  begin
    new_flow = client.create_application_flow(
      app_revision_id,
      NEW_FLOW_NAME,
      [NETWORK_OBJECT_IP],
      [NETWORK_OBJECT_IP],
      [NETWORK_SERVICE_NAME],
      [],
      [],
      'Flow Created by AlgoSec Ruby SDK'
    )
    puts "Flow created successfully: #{new_flow}"
    puts "Flow created successfully. Flow ID is: #{new_flow['flowID']}"
  rescue StandardError => ex
    puts "Application flow creation failed with: #{ex}"

  end

  puts "Trying to fetch the pre-existing flow by it's name, due to bug in the returned new flowID"
  new_flow = client.get_application_flow_by_name(app_revision_id, NEW_FLOW_NAME)
  puts 'Flow successfully fetched by name'

  # Refresh the app revision id in case a draft was created
  app_revision_id = client.get_app_revision_id_by_name(args.app)

  puts 'Getting flow connectivity'
  flow_connectivity = client.get_flow_connectivity(app_revision_id, new_flow['flowID'])
  puts "Fetched flow connectivity: #{flow_connectivity}"

  puts 'Deleting the flow now'
  client.delete_flow_by_id(app_revision_id, new_flow['flowID'])
  puts 'Flow deleted successfully'

  puts 'Fetching current application flows'
  flows = client.get_application_flows(app_revision_id)
  puts "#{flows.length} flows fetched"


  puts '### END-TO-END INTEGRATION END ###'
end
