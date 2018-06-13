require 'set'

module ALGOSEC_SDK
  ANY_OBJECT = { id: 0, name: 'Any' }.to_json.freeze
  ANY_NETWORK_APPLICATION = { revisionID: 0, name: 'Any' }.to_json.freeze
  # A module to determine if a local flow definition is equal to a flow defined on the server
  module AreFlowsEqual
    def self.are_sources_equal_in_flow(source_object_names, network_flow)
      flow_source_object_names = Set.new(network_flow['sources'].map { |source| source['name'] })
      Set.new(source_object_names) == Set.new(flow_source_object_names)
    end

    def self.are_dest_equal_in_flow(dest_object_names, network_flow)
      flow_dest_object_names = Set.new(network_flow['destinations'].map { |dest| dest['name'] })
      Set.new(dest_object_names) == Set.new(flow_dest_object_names)
    end

    def self.are_services_equal_in_flow(service_names, network_flow)
      network_flow_service_names = Set.new(network_flow['services'].map { |service| service['name'] })
      Set.new(service_names) == Set.new(network_flow_service_names)
    end

    def self.are_apps_equal_in_flow(application_names, network_flow)
      if network_flow['networkApplications'] == [ANY_NETWORK_APPLICATION]
        return application_names == []
      end
      flow_application_names = network_flow['networkApplications'].map do |network_application|
        network_application['name']
      end

      Set.new(application_names) == Set.new(flow_application_names)
    end

    def self.are_users_equal_in_flow(network_users, network_flow)
      return network_users == [] if network_flow['networkUsers'] == [ANY_OBJECT]
      flow_users = network_flow['networkUsers'].map { |user| user['name'] }
      Set.new(network_users) == Set.new(flow_users)
    end

    def self.flows_equal?(new_flow, flow_from_server)
      [
        are_sources_equal_in_flow(new_flow['sources'], flow_from_server),
        are_dest_equal_in_flow(new_flow['destinations'], flow_from_server),
        are_services_equal_in_flow(new_flow['network_services'], flow_from_server),
        are_apps_equal_in_flow(new_flow['network_applications'], flow_from_server),
        are_users_equal_in_flow(new_flow['network_users'], flow_from_server)
      ].all?
    end
  end
end
