# frozen_string_literal: true

require 'set'

module ALGOSEC_SDK
  ANY_OBJECT = { 'id' => 0, 'name' => 'Any' }.freeze
  ANY_NETWORK_APPLICATION = { 'revisionID' => 0, 'name' => 'Any' }.freeze
  # A module to determine if a local flow definition is equal to a flow defined on the server
  module AreFlowsEqual
    def self.are_sources_equal_in_flow(source_object_names, server_flow_sources)
      flow_source_object_names = Set.new(server_flow_sources.map { |source| source['name'] })
      Set.new(source_object_names) == Set.new(flow_source_object_names)
    end

    def self.are_dest_equal_in_flow(dest_object_names, server_flow_dests)
      flow_dest_object_names = Set.new(server_flow_dests.map { |dest| dest['name'] })
      Set.new(dest_object_names) == Set.new(flow_dest_object_names)
    end

    def self.are_services_equal_in_flow(service_names, server_flow_services)
      network_flow_service_names = Set.new(server_flow_services.map { |service| service['name'] })
      Set.new(service_names) == Set.new(network_flow_service_names)
    end

    def self.are_apps_equal_in_flow(application_names, server_flow_apps)
      return application_names == [] if server_flow_apps == [ANY_NETWORK_APPLICATION]
      flow_application_names = server_flow_apps.map do |network_application|
        network_application['name']
      end

      Set.new(application_names) == Set.new(flow_application_names)
    end

    def self.are_users_equal_in_flow(network_users, server_flow_users)
      return network_users == [] if server_flow_users == [ANY_OBJECT]
      flow_users = server_flow_users.map { |user| user['name'] }
      Set.new(network_users) == Set.new(flow_users)
    end

    def self.flows_equal?(new_flow, flow_from_server)
      [
        are_sources_equal_in_flow(new_flow['sources'], flow_from_server['sources']),
        are_dest_equal_in_flow(new_flow['destinations'], flow_from_server['destinations']),
        are_services_equal_in_flow(new_flow['services'], flow_from_server['services']),
        are_apps_equal_in_flow(new_flow.fetch('applications', []), flow_from_server.fetch('networkApplications', [])),
        are_users_equal_in_flow(new_flow.fetch('users', []), flow_from_server.fetch('networkUsers', []))
      ].all?
    end
  end
end
