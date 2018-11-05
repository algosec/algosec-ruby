# frozen_string_literal: true

require_relative 'flow_comparisons'
require 'set'
require 'ipaddress'

module ALGOSEC_SDK
  module NetworkObjectType
    HOST = 'Host'.freeze
    RANGE = 'Range'.freeze
    GROUP = 'Group'.freeze
    ABSTRACT = 'Abstract'.freeze
  end
end

module ALGOSEC_SDK
  module NetworkObjectSearchType
    INTERSECT = 'INTERSECT'.freeze
    CONTAINED = 'CONTAINED'.freeze
    CONTAINING = 'CONTAINING'.freeze
    EXACT = 'EXACT'.freeze
  end
end

module ALGOSEC_SDK
  # Contains helper methods for BusinessFlow
  module BusinessFlowHelper
    # Request login to get session cookie credentials
    # @raise [RuntimeError] if the request failed
    # @return [Array<Hash>] flows
    def login
      response_handler(rest_post('/BusinessFlow/rest/v1/login'))
    end

    # Create an application
    # @param [String] name The application's name.
    # @param [Array<String>] custom_fields Existing custom fields to assign to the application.
    # @param [Array<String>] contacts Existing contacts to assign to the application.
    # @param [Array<String>] labels Existing labels to assign to the application.
    # @param [Array<String>] flows The flows to add to the application upon creation.
    # @raise [RuntimeError] if the request failed
    # @return Newly created Application object
    def create_application(
      name,
      custom_fields = [],
      contacts = [],
      labels = [],
      flows = []
    )
      new_application = {
        name: name,
        custom_fields: custom_fields,
        contacts: contacts,
        labels: labels,
        flows: flows
      }
      response = rest_post('/BusinessFlow/rest/v1/applications/new', body: new_application)
      response_handler(response)
    end

    # Decommission an application
    # @param [String] app_revision_id
    # @raise [RuntimeError] if the request failed
    # @return true
    def decommission_application(app_revision_id)
      response = rest_post("/BusinessFlow/rest/v1/applications/#{app_revision_id}/decommission")
      response_handler(response)
    end

    # Get list of application flows for an application revision id
    # @param [String, Symbol] app_revision_id
    # @raise [RuntimeError] if the request failed
    # @return [Array<Hash>] flows
    def get_application_flows(app_revision_id)
      response = rest_get("/BusinessFlow/rest/v1/applications/#{app_revision_id}/flows")
      flows = response_handler(response)
      flows.map { |flow| flow['flowType'] == 'APPLICATION_FLOW' ? flow : nil }.compact
    end

    # Get application flows from the server as a hash from flow name it it's content
    # @param [String, Symbol] app_revision_id
    # @raise [RuntimeError] if the request failed
    # @return [Hash] flows as a hash from name to flow
    def get_application_flows_hash(app_revision_id)
      Hash[get_application_flows(app_revision_id).map { |flow| [flow['name'], flow] }]
    end

    # Delete a specific flow
    # @param [String] app_revision_id
    # @param [String] flow_id
    # @raise [RuntimeError] if the request failed
    # @return true
    def delete_flow_by_id(app_revision_id, flow_id)
      response = rest_delete("/BusinessFlow/rest/v1/applications/#{app_revision_id}/flows/#{flow_id}")
      response_handler(response)
      true
    end

    # Get connectivity status for a flow
    # @param [String] app_revision_id
    # @param [String] flow_id
    # @raise [RuntimeError] if the request failed
    # @return [String] Connectivity Status dict that contain flowId, queryLink and status keys
    def get_flow_connectivity(app_revision_id, flow_id)
      response = rest_post("/BusinessFlow/rest/v1/applications/#{app_revision_id}/flows/#{flow_id}/check_connectivity")
      response_handler(response)
    end

    # Create a flow
    # @param [String] app_revision_id The application revision id to create the flow in
    # @param [Object] flow_name
    # @param [Array<String>] sources
    # @param [Array<String>] destinations
    # @param [Array<String>] network_users
    # @param [Array<String>] network_apps
    # @param [Array<String>] network_services
    # @param [String] comment
    # @param [String] type
    # @raise [RuntimeError] if the request failed
    # @return Newly created application flow
    # rubocop:disable Metrics/ParameterLists
    def create_application_flow(
      app_revision_id,
      flow_name,
      sources,
      destinations,
      network_services,
      network_users,
      network_apps,
      comment,
      type = 'APPLICATION',
      custom_fields = []
    )
      # rubocop:enable Metrics/ParameterLists

      # Create the missing network objects from the sources and destinations
      create_missing_network_objects(sources + destinations)
      create_missing_services(network_services)

      get_named_objects = ->(name_list) { name_list.map { |name| { name: name } } }

      new_flow = {
        name: flow_name,
        sources: get_named_objects.call(sources),
        destinations: get_named_objects.call(destinations),
        users: network_users,
        network_applications: get_named_objects.call(network_apps),
        services: get_named_objects.call(network_services),
        comment: comment,
        type: type,
        custom_fields: custom_fields
      }
      response = rest_post("/BusinessFlow/rest/v1/applications/#{app_revision_id}/flows/new", body: [new_flow])
      flows = response_handler(response)
      # AlgoSec return a list of created flows, we created only one
      flows[0]
    end

    # Fetch an application flow by it's name
    # @param [String] app_revision_id The application revision id to fetch the flow from
    # @param [Object] flow_name
    # @raise [RuntimeError] if the request failed
    # @return The requested flow
    def get_application_flow_by_name(app_revision_id, flow_name)
      flows = get_application_flows(app_revision_id)
      requested_flow = flows.find do |flow|
        break flow if flow['name'] == flow_name
      end

      if requested_flow.nil?
        raise(
          "Unable to find flow by name. Application revision id: #{app_revision_id}, flow_name: #{flow_name}."
        )
      end
      requested_flow
    end

    # Get all applications
    # @raise [RuntimeError] if the request failed
    # @return [Array<Hash>] application objects
    def get_applications
      response = rest_get('/BusinessFlow/rest/v1/applications/')
      response_handler(response)
    end

    # Get application by name
    # @param [String, Symbol] app_name
    # @raise [RuntimeError] if the request failed
    # @return [Hash] application object
    def get_application_by_name(app_name)
      response = rest_get("/BusinessFlow/rest/v1/applications/name/#{app_name}")
      response_handler(response)
    end

    # Get latest application revision id by application name
    # @param [String, Symbol] app_name
    # @raise [RuntimeError] if the request failed
    # @return [Boolean] application revision id
    def get_app_revision_id_by_name(app_name)
      get_application_by_name(app_name)['revisionID']
    end

    # Get application id by it's name
    # @param [String, Symbol] app_name
    # @raise [RuntimeError] if the request failed
    # @return [Boolean] application id
    def get_app_id_by_name(app_name)
      get_application_by_name(app_name)['applicationId']
    end

    # Apply application draft
    # @param [String] app_revision_id
    # @raise [RuntimeError] if the request failed
    # @return true
    def apply_application_draft(app_revision_id)
      response = rest_post("/BusinessFlow/rest/v1/applications/#{app_revision_id}/apply")
      response_handler(response)
      true
    end

    # Create a new network service
    # @param [String] service_name
    # @param content List of lists in the form of (protocol, port)
    # @raise [RuntimeError] if the request failed
    # @return true if service created or already exists
    def create_network_service(service_name, content)
      content = content.map { |service| { protocol: service[0], port: service[1] } }
      new_service = { name: service_name, content: content }
      response = rest_post('/BusinessFlow/rest/v1/network_services/new', body: new_service)
      response_handler(response)
      true
    end

    # Create a new network object
    # @param [NetworkObjectType] type type of the object to be created
    # @param [String] content Define the newly created network object. Content depend upon the selected type
    # @param [String] name Name of the new network object
    # @raise [RuntimeError] if the request failed
    # @return Newly created object
    def create_network_object(type, content, name)
      new_object = { type: type, name: name, content: content }
      response = rest_post('/BusinessFlow/rest/v1/network_objects/new', body: new_object)
      response_handler(response)
    end

    # Search a network object
    # @param [String] ip_or_subnet The ip or subnet to search the object with
    # @param [NetworkObjectSearchType] search_type type of the object search method
    # @raise [RuntimeError] if theh request failed
    # @return List of objects from the search result
    def search_network_object(ip_or_subnet, search_type)
      response = rest_get(
        '/BusinessFlow/rest/v1/network_objects/find',
        query: { address: ip_or_subnet, type: search_type }
      )
      response_handler(response)
    end

    # Return a plan for modifying application flows based on current and newly proposed application flows definition
    # @param [Array<Hash>] server_app_flows List of app flows currently defined on the server
    # @param [Array<Hash>] new_app_flows List of network flows hash definitions
    # @raise [RuntimeError] if the request failed
    # @return 3 lists of flow names: flows_to_delete, flows_to_create, flows_to_modify
    def plan_application_flows(server_app_flows, new_app_flows)
      current_flow_names = Set.new(server_app_flows.keys)
      new_flow_names = Set.new(new_app_flows.keys)
      # Calculate the flows_to_delete, flows_to_create and flows_to_modify and unchanging_flows
      flows_to_delete = current_flow_names - new_flow_names
      flows_to_create = new_flow_names - current_flow_names
      flows_to_modify = Set.new((new_flow_names & current_flow_names).map do |flow_name|
        flow_on_server = server_app_flows[flow_name]
        new_flow_definition = new_app_flows[flow_name]
        ALGOSEC_SDK::AreFlowsEqual.flows_equal?(new_flow_definition, flow_on_server) ? nil : flow_name
      end.compact)

      [flows_to_delete, flows_to_create, flows_to_modify]
    end

    # Create/modify/delete application2 flows to match a given flow plan returned by 'plan_application_flows'
    # @param [Integer] app_name The app to create the flows for
    # @param [Array<Hash>] new_app_flows List of network flows hash definitions
    # @param [Array<Hash>] flows_from_server List of network flows objects fetched from the server
    # @param [Array<String>] flows_to_delete List of network flow names for deletion
    # @param [Array<String>] flows_to_create List of network flow names to create
    # param [Array<String>] flows_to_modify List of network flow names to delete and re-create with the new definition
    # @raise [RuntimeError] if any of the requests failed
    # @return True
    def implement_app_flows_plan(
      app_name,
      new_app_flows,
      flows_from_server,
      flows_to_delete,
      flows_to_create,
      flows_to_modify
    )
      # Get the app revision id
      app_revision_id = get_app_revision_id_by_name(app_name)

      # This param is used to determine if it is necessary to update the app_revision_id
      is_draft_revision = false

      # Delete all the flows for deletion and modification
      (flows_to_delete | flows_to_modify).each do |flow_name_to_delete|
        delete_flow_by_id(app_revision_id, flows_from_server[flow_name_to_delete]['flowID'])
        next if is_draft_revision
        app_revision_id = get_app_revision_id_by_name(app_name)
        # Refetch the fresh flows from the server, as a new application revision has been created
        # and it's flow IDs have been change. Only that way we can make sure that the following flow deletions
        # by name will work as expected
        flows_from_server = get_application_flows_hash(app_revision_id)
        is_draft_revision = true
      end
      # Create all the new + modified flows
      (flows_to_create | flows_to_modify).each do |flow_name_to_create|
        new_flow_data = new_app_flows[flow_name_to_create]
        create_application_flow(
          app_revision_id,
          flow_name_to_create,
          # Document those key fields somewhere so users know how what is the format of app_flows object
          # that is provided to this function
          new_flow_data['sources'],
          new_flow_data['destinations'],
          new_flow_data['services'],
          new_flow_data.fetch('users', []),
          new_flow_data.fetch('applications', []),
          new_flow_data.fetch('comment', '')
        )
        unless is_draft_revision
          app_revision_id = get_app_revision_id_by_name(app_name)
          is_draft_revision = true
        end
      end

      apply_application_draft(app_revision_id) if is_draft_revision
    end

    # Update application flows of an application to match a requested flows configuration.
    # @param [Integer] app_name The app to create the flows for
    # @param [Object] new_app_flows Hash of new app flows, pointing from the flow name to the flow definition
    # @raise [RuntimeError] if the request failed
    # @return The updated list of flow objects from the server, including their new flowID
    def define_application_flows(app_name, new_app_flows)
      flows_from_server = get_application_flows_hash(get_app_revision_id_by_name(app_name))
      flows_to_delete, flows_to_create, flows_to_modify = plan_application_flows(flows_from_server, new_app_flows)
      implement_app_flows_plan(
        app_name,
        new_app_flows,
        flows_from_server,
        flows_to_delete,
        flows_to_create,
        flows_to_modify
      )

      # Stage 2: Run connectivity check for all the unchanged flows. Check with Chef is this non-deterministic approach
      # is OK with them for the cookbook.
      #
      # Return the current list of created flows if successful
      get_application_flows(get_app_revision_id_by_name(app_name))
    end

    # Create all the missing network objects which are simple IPv4 ip or subnet
    # @param [Array<String>] network_object_names List of the network object names
    # @raise [RuntimeError] if the request failed
    # @return Newly created objects
    def create_missing_network_objects(network_object_names)
      # TODO: Add unitests that objects are being create only once (if the same object is twice in the incoming list)
      network_object_names = Set.new(network_object_names)
      ipv4_or_subnet_objects = network_object_names.map do |object_name|
        begin
          IPAddress.parse object_name
          search_result = search_network_object(object_name, NetworkObjectSearchType::EXACT)
          # If no object was found in search, we'll count this object for creation
          search_result.empty? ? object_name : nil
        rescue ArgumentError
          # The parsed object name was not IP Address or IP Subnet, ignore it
          nil
        end
      end.compact

      # Create all the objects. If the error from the server tells us that the object already exists, ignore the error
      ipv4_or_subnet_objects.map do |ipv4_or_subnet|
        create_network_object(NetworkObjectType::HOST, ipv4_or_subnet, ipv4_or_subnet)
      end.compact
    end

    # Create all the missing network services which are of simple protocol/port pattern
    # @param [Array<String>] service_names List of the network service names
    # @raise [RuntimeError] if the request failed
    # @return Newly created objects
    def create_missing_services(service_names)
      parsed_services = service_names.map do |service_name|
        protocol, port = service_name.scan(%r{(TCP|UDP)/(\d+)}i).last
        [service_name, [protocol, port]] if !protocol.nil? && !port.nil?
      end.compact
      # Create all the objects. If the error from the server tells us that the object already exists, ignore the error
      parsed_services.map do |parsed_service|
        service_name, service_content = parsed_service
        begin
          create_network_service(service_name, [service_content])
        rescue StandardError => e
          # If the error is different from "service already exists", the exception will be re-raised
          raise e if e.to_s.index('Service name already exists').nil?
        end
      end.compact
    end
  end
end
