require_relative './../../spec_helper'

RSpec.describe ALGOSEC_SDK::AreFlowsEqual do
  before(:each) do
    @flow_compare = ALGOSEC_SDK::AreFlowsEqual
  end
  describe '#are_sources_equal_in_flow#' do
    it 'test the func' do
      expect(
        @flow_compare.are_sources_equal_in_flow(
          %w[objectName1 objectName2],
          'sources' => [{ 'name' => 'objectName1' }, { 'name' => 'objectName2' }]
        )
      ).to equal(true)

      expect(
        @flow_compare.are_sources_equal_in_flow(
          %w[objectName1],
          'sources' => [{ 'name' => 'UnknownObjectName' }]
        )
      ).to equal(false)
    end
  end
  describe '#are_dest_equal_in_flow#' do
    it 'test the func' do
      expect(
        @flow_compare.are_dest_equal_in_flow(
          %w[objectName1 objectName2],
          'destinations' => [{ 'name' => 'objectName1' }, { 'name' => 'objectName2' }]
        )
      ).to equal(true)

      expect(
        @flow_compare.are_dest_equal_in_flow(
          %w[objectName1],
          'destinations' => [{ 'name' => 'UnknownObjectName' }]
        )
      ).to equal(false)
    end
  end
  describe '#are_services_equal_in_flow#' do
    it 'test the func' do
      # TODO: Make sure that we have no issues with case sensitiveness of TCP/80 vs tcp/80 for any of the protocols
      expect(
        @flow_compare.are_services_equal_in_flow(
          %w[service1 service2],
          'services' => [
            { 'name' => 'service2' },
            { 'name' => 'service1' }
          ]
        )
      ).to equal(true)

      expect(
        @flow_compare.are_services_equal_in_flow(
          ['service2'],
          'services' => [{ 'name' => 'service1' }]
        )
      ).to equal(false)
    end
  end
  describe '#are_apps_equal_in_flow#' do
    it 'test the func' do
      expect(
        @flow_compare.are_apps_equal_in_flow(
          %w[app1 app2],
          'networkApplications' => [{ 'name' => 'app1' }, { 'name' => 'app2' }]
        )
      ).to equal(true)

      expect(
        @flow_compare.are_apps_equal_in_flow(
          %w[app1 app2 app3],
          'networkApplications' => [{ 'name' => 'app1' }, { 'name' => 'app2' }]
        )
      ).to equal(false)

      # Test the case where the network applications are set to ANY on the server
      expect(
        @flow_compare.are_apps_equal_in_flow(
          [],
          'networkApplications' => [ALGOSEC_SDK::ANY_NETWORK_APPLICATION]
        )
      ).to equal(true)

      expect(
        @flow_compare.are_apps_equal_in_flow(
          %w[app1],
          'networkApplications' => [ALGOSEC_SDK::ANY_NETWORK_APPLICATION]
        )
      ).to equal(false)
    end
  end
  describe '#are_users_equal_in_flow#' do
    it 'test the func' do
      expect(
        @flow_compare.are_users_equal_in_flow(
          %w[user1 user2],
          'networkUsers' => [{ 'name' => 'user1' }, { 'name' => 'user2' }]
        )
      ).to equal(true)

      expect(
        @flow_compare.are_users_equal_in_flow(
          %w[user1 UnknownUser],
          'networkUsers' => [{ 'name' => 'user1' }, { 'name' => 'user2' }]
        )
      ).to equal(false)

      # Test the case where the network users are set to ANY on the server
      expect(
        @flow_compare.are_users_equal_in_flow(
          ['user1'],
          'networkUsers' => [ALGOSEC_SDK::ANY_OBJECT]
        )
      ).to equal(false)

      expect(
        @flow_compare.are_users_equal_in_flow(
          [],
          'networkUsers' => [ALGOSEC_SDK::ANY_OBJECT]
        )
      ).to equal(true)
    end
  end
  describe '#flows_equal?#' do
    it 'positive cases' do
      new_flow = {
        'sources' => 'sources',
        'destinations' => 'destinations',
        'services' => 'network_services',
        'applications' => 'network_applications',
        'users' => 'network_users'
      }

      server_flow = Object.new
      expect(@flow_compare).to receive(:are_sources_equal_in_flow).with(
        new_flow['sources'], server_flow
      ).and_return(true)
      expect(@flow_compare).to receive(:are_dest_equal_in_flow).with(
        new_flow['destinations'], server_flow
      ).and_return(true)
      expect(@flow_compare).to receive(:are_services_equal_in_flow).with(
        new_flow['services'], server_flow
      ).and_return(true)
      expect(@flow_compare).to receive(:are_apps_equal_in_flow).with(
        new_flow['applications'], server_flow
      ).and_return(true)
      expect(@flow_compare).to receive(:are_users_equal_in_flow).with(
        new_flow['users'], server_flow
      ).and_return(true)

      expect(
        @flow_compare.flows_equal?(new_flow, server_flow)
      ).to equal(true)
    end
    it 'negative cases' do
      new_flow = {
        'sources' => 'sources',
        'destinations' => 'destinations',
        'services' => 'services',
        'applications' => 'applications',
        'users' => 'users'
      }

      server_flow = Object.new
      expect(@flow_compare).to receive(:are_sources_equal_in_flow).with(
        new_flow['sources'], server_flow
      ).and_return(false)
      expect(@flow_compare).to receive(:are_dest_equal_in_flow).with(
        new_flow['destinations'], server_flow
      ).and_return(true)
      expect(@flow_compare).to receive(:are_services_equal_in_flow).with(
        new_flow['services'], server_flow
      ).and_return(true)
      expect(@flow_compare).to receive(:are_apps_equal_in_flow).with(
        new_flow['applications'], server_flow
      ).and_return(true)
      expect(@flow_compare).to receive(:are_users_equal_in_flow).with(
        new_flow['users'], server_flow
      ).and_return(true)

      expect(
        @flow_compare.flows_equal?(new_flow, server_flow)
      ).to equal(false)
    end
    it 'default values are used for applications and users' do
      new_flow = {
        'sources' => 'sources',
        'destinations' => 'destinations',
        'services' => 'services'
      }

      server_flow = Object.new
      expect(@flow_compare).to receive(:are_sources_equal_in_flow).with(
        new_flow['sources'], server_flow
      ).and_return(false)
      expect(@flow_compare).to receive(:are_dest_equal_in_flow).with(
        new_flow['destinations'], server_flow
      ).and_return(true)
      expect(@flow_compare).to receive(:are_services_equal_in_flow).with(
        new_flow['services'], server_flow
      ).and_return(true)
      expect(@flow_compare).to receive(:are_apps_equal_in_flow).with(
        [], server_flow
      ).and_return(true)
      expect(@flow_compare).to receive(:are_users_equal_in_flow).with(
        [], server_flow
      ).and_return(true)

      expect(
        @flow_compare.flows_equal?(new_flow, server_flow)
      ).to equal(false)
    end
  end
end
