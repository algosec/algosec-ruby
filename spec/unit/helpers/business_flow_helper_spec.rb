# frozen_string_literal: true

require_relative './../../spec_helper'

RSpec.describe ALGOSEC_SDK::BusinessFlowHelper do
  include_context 'shared context'
  describe '#login#' do
    it 'makes a POST rest call' do
      fake_response = FakeResponse.new
      expect(@client).to receive(:rest_post).with('/BusinessFlow/rest/v1/login').and_return(fake_response)
      expect(@client).to receive(:response_handler).with(fake_response)
      @client.login
    end
  end
  describe '#create_application#' do
    it 'makes a POST rest call' do
      new_app = {
        name: 'application-name',
        custom_fields: [{ name: 'field1', value: 'value1' }, { name: 'field2', value: 'value2' }],
        contacts: [{ email: 'email1', role: 'role1' }, { email: 'email2', role: 'role2' }],
        labels: %w[label1 label2],
        flows: [{ name: 'flow-name1' }, { name: 'flow-name2' }]
      }
      fake_response = FakeResponse.new(new_app)
      expect(@client).to receive(:rest_post).with(
        '/BusinessFlow/rest/v1/applications/new',
        body: new_app
      ).and_return(fake_response)
      ret_val = @client.create_application(
        'application-name',
        [{ name: 'field1', value: 'value1' }, { name: 'field2', value: 'value2' }],
        [{ email: 'email1', role: 'role1' }, { email: 'email2', role: 'role2' }],
        %w[label1 label2],
        [{ name: 'flow-name1' }, { name: 'flow-name2' }]
      )
      expect(ret_val.to_json).to eq(new_app.to_json)
    end
    it 'makes a POST call with default values' do
      new_app = {
        name: 'application-name',
        custom_fields: [],
        contacts: [],
        labels: [],
        flows: []
      }
      fake_response = FakeResponse.new(new_app)
      expect(@client).to receive(:rest_post).with(
        '/BusinessFlow/rest/v1/applications/new',
        body: new_app
      ).and_return(fake_response)
      ret_val = @client.create_application('application-name')
      expect(ret_val.to_json).to eq(new_app.to_json)
    end
  end
  describe '#delete_application_flow#' do
    it 'makes a POST rest call' do
      change_application_response = {
        Application: 'application-obj',
        ChangeRequest: 'change-request-object'
      }
      fake_response = FakeResponse.new(change_application_response)
      expect(@client).to receive(:rest_post).with(
        '/BusinessFlow/rest/v1/applications/application-id/decommission'
      ).and_return(fake_response)
      ret_val = @client.decommission_application('application-id')
      expect(ret_val.to_json).to eq(change_application_response.to_json)
    end
  end
  describe '#get_application_flows#' do
    it 'makes a GET rest call' do
      # rubocop:disable Style/NumericLiterals
      body = [
        {
          'comment' => '',
          'connectivityStatus' => nil,
          'createdDate' => 1520353392998,
          'destinations' => [
            {
              'createdDate' => 1518136428537,
              'ipAddresses' => ['192.168.2.2'],
              'lastUpdateDate' => 1518136428539,
              'name' => '192.168.2.2',
              'objectID' => 13293,
              'objectType' => 'Host',
              'origin' => 'Imported from file',
              'revisionID' => 13293
            }
          ],
          'flowID' => 1477,
          'flowType' => 'APPLICATION_FLOW',
          'lastUpdateDate' => 1520353393013,
          'name' => 'flow-from-api-1',
          'networkApplications' => [{ 'name' => 'Any', 'revisionID' => 0 }],
          'networkUsers' => [{ 'id' => 0, 'name' => 'Any' }],
          'services' => [
            {
              'createdDate' => 1518047934038,
              'lastUpdateDate' => 1518047934048,
              'name' => 'TCP/200',
              'origin' => 'Imported from file',
              'revisionID' => 15069,
              'serviceID' => 15069,
              'services' => ['TCP/200']
            }
          ],
          'sources' => [
            {
              'createdDate' => 1518136372407,
              'ipAddresses' => ['192.168.2.1'],
              'lastUpdateDate' => 1518136372410,
              'name' => '192.168.2.1',
              'objectID' => 13292,
              'objectType' => 'Host',
              'origin' => 'Imported from file',
              'revisionID' => 13292
            }
          ]
        }
      ]
      # rubocop:enable Style/NumericLiterals
      fake_response = FakeResponse.new(body)
      expect(@client).to receive(:rest_get).with(
        '/BusinessFlow/rest/v1/applications/app-revision-id/flows'
      ).and_return(fake_response)
      flows = @client.get_application_flows('app-revision-id')
      expect(flows).to eq(body)
    end
  end
  describe '#get_application_by_name#' do
    it 'makes a GET rest call' do
      body = {
        "revisionID": 372,
        "applicationID": 348,
        "name": 'TEST',
        "createdDate": 1_530_039_923_359,
        "revisionStatus": 'Draft',
        "lifecyclePhase": 'Testing',
        "connectivityStatus": 'No connectivity information',
        "lastUpdateDate": 1_531_509_201_690,
        "vulnerabilityScore": 80
      }
      fake_response = FakeResponse.new(body)
      expect(@client).to receive(:rest_get).with(
        '/BusinessFlow/rest/v1/applications/name/application-name'
      ).and_return(fake_response)
      application = @client.get_application_by_name('application-name')
      expect(application).to eq(body)
    end
  end
  describe '#get_application_flows_hash#' do
    it 'convert the flows from server to hash from name to flow data' do
      app_revision_id = anything
      flow1 = {
        'name' => 'flow1',
        'data' => 'flow1-data'
      }
      flow2 = {
        'name' => 'flow2',
        'data' => 'flow2-data'
      }
      server_flows = [flow1, flow2]
      expect(@client).to receive(:get_application_flows).with(app_revision_id).and_return(server_flows)
      hash_flows = @client.get_application_flows_hash(app_revision_id)
      expect(hash_flows).to eq('flow1' => flow1, 'flow2' => flow2)
    end
  end
  describe '#delete_flow_by_id#' do
    it 'makes a DELETE rest call' do
      expect(@client).to receive(:rest_delete).with(
        '/BusinessFlow/rest/v1/applications/app-revision-id/flows/flow-id'
      ).and_return(FakeResponse.new)
      ret_val = @client.delete_flow_by_id('app-revision-id', 'flow-id')
      expect(ret_val).to eq(true)
    end
  end
  describe '#get_flow_connectivity#' do
    it 'makes a GET rest call' do
      body = {
        'flowId' => 1477,
        'queryLink' => 'https://192.168.58.128/fa/query/results/#/work/ALL_FIREWALLS_query-3656/',
        'status' => 'Pass'
      }
      fake_response = FakeResponse.new(body)
      expect(@client).to receive(:rest_post).with(
        '/BusinessFlow/rest/v1/applications/app-revision-id/flows/flow-id/check_connectivity'
      ).and_return(fake_response)
      flow_connectivity = @client.get_flow_connectivity('app-revision-id', 'flow-id')
      expect(flow_connectivity).to eq(body)
    end
  end
  describe '#create_application_flow#' do
    it 'makes a POST rest call' do
      new_flow = {
        name: 'flow-name',
        sources: [{ name: 'source1' }, { name: 'source2' }],
        destinations: [{ name: 'dest1' }, { name: 'dest2' }],
        users: %w[user1 user2],
        network_applications: [{ name: 'app1' }, { name: 'app2' }],
        services: [{ name: 'service1' }, { name: 'service2' }],
        comment: 'Comment',
        type: 'APPLICATION',
        custom_fields: []
      }
      fake_response = FakeResponse.new([new_flow])
      expect(@client).to receive(:create_missing_network_objects).with(%w[source1 source2 dest1 dest2])
      expect(@client).to receive(:create_missing_services).with(%w[service1 service2])
      expect(@client).to receive(:rest_post).with(
        '/BusinessFlow/rest/v1/applications/app-revision-id/flows/new',
        body: [new_flow]
      ).and_return(fake_response)
      ret_val = @client.create_application_flow(
        'app-revision-id',
        'flow-name',
        %w[source1 source2],
        %w[dest1 dest2],
        %w[service1 service2],
        %w[user1 user2],
        %w[app1 app2],
        'Comment'
      )
      expect(ret_val.to_json).to eq(new_flow.to_json)
    end
  end
  describe '#get_applications#' do
    it 'makes a GET rest call' do
      applications = [{ 'name' => 'app1' }, { 'name' => 'app2' }]
      fake_response = FakeResponse.new(applications)
      expect(@client).to receive(:rest_get).with(
        '/BusinessFlow/rest/v1/applications/'
      ).and_return(fake_response)
      result = @client.get_applications
      expect(result).to eq(applications)
    end
  end
  describe '#get_app_revision_id_by_name#' do
    it 'makes a GET rest call' do
      app_revision_id = 410
      app = { 'revisionID' => app_revision_id }
      expect(@client).to receive(:get_application_by_name).with('application-name').and_return(app)
      app_revision = @client.get_app_revision_id_by_name('application-name')
      expect(app_revision).to eq(app_revision_id)
    end
  end
  describe '#get_app_id_by_name#' do
    it 'makes a GET rest call' do
      app_id = 410
      app = { 'applicationId' => app_id }
      expect(@client).to receive(:get_application_by_name).with('application-name').and_return(app)
      app = @client.get_app_id_by_name('application-name')
      expect(app).to eq(app_id)
    end
  end
  describe '#apply_application_draft#' do
    it 'makes a POST rest call' do
      expect(@client).to receive(:rest_post).with(
        '/BusinessFlow/rest/v1/applications/app-revision-id/apply'
      ).and_return(FakeResponse.new)
      ret_val = @client.apply_application_draft('app-revision-id')
      expect(ret_val).to eq(true)
    end
  end
  describe '#create_network_service#' do
    it 'makes a POST rest call' do
      new_service = {
        name: 'service-name',
        content: [{ protocol: 'tcp', port: '123' }, { protocol: 'udp', port: '500' }]
      }
      expect(@client).to receive(:rest_post).with(
        '/BusinessFlow/rest/v1/network_services/new', body: new_service
      ).and_return(FakeResponse.new)
      ret_val = @client.create_network_service('service-name', [%w[tcp 123], %w[udp 500]])
      expect(ret_val).to eq(true)
    end
  end
  describe '#create_network_object#' do
    it 'makes a POST rest call' do
      new_action = {
        type: 'Host',
        name: 'object-name',
        content: '192.168.1.1'
      }

      new_network_object = { 'objectID' => 123 }
      fake_response = FakeResponse.new(new_network_object)
      expect(@client).to receive(:rest_post).with(
        '/BusinessFlow/rest/v1/network_objects/new', body: new_action
      ).and_return(fake_response)
      ret_val = @client.create_network_object('Host', '192.168.1.1', 'object-name')
      expect(ret_val).to eq(new_network_object)
    end
  end
  describe '#search_network_object#' do
    it 'makes a GET rest call' do
      search_result = [{ 'objectID' => 123 }]
      fake_response = FakeResponse.new(search_result)
      expect(@client).to receive(:rest_get).with(
        '/BusinessFlow/rest/v1/network_objects/find', query: { address: 'ip-or-subnet', type: 'search-type' }
      ).and_return(fake_response)
      ret_val = @client.search_network_object('ip-or-subnet', 'search-type')
      expect(ret_val).to eq(search_result)
    end
  end
  describe '#get_application_flow_by_name#' do
    it 'flow is found on the server' do
      app_revision_id = 410
      requested_flow = { 'name' => 'flow2' }
      app_flows = [{ 'name' => 'flow1' }, requested_flow]
      expect(@client).to receive(:get_application_flows).with(app_revision_id).and_return(app_flows)

      flow = @client.get_application_flow_by_name(app_revision_id, 'flow2')
      expect(flow).to eq(requested_flow)
    end
    it 'flow is not found on the server' do
      app_revision_id = 410
      app_flows = [{ 'name' => 'flow1' }, { 'name' => 'flow2' }]
      expect(@client).to receive(:get_application_flows).with(app_revision_id).and_return(app_flows)
      expect do
        @client.get_application_flow_by_name(app_revision_id, 'flow3')
      end.to raise_error(RuntimeError)
    end
  end
  describe '#create_missing_network_objects#' do
    let(:missing_object) {}
    let(:create_missing_objects) { @client.create_missing_network_objects([missing_object]) }

    shared_examples_for 'IP/CIDR/Range missing objects' do
      it 'searches for the object' do
        expect(@client).to receive(:search_network_object).with(
          missing_object, ALGOSEC_SDK::NetworkObjectSearchType::EXACT
        ).and_return([])
        allow(@client).to receive(:create_network_object).and_return('created_object')
        create_missing_objects
      end
      it 'creates the object if there are no search results' do
        expect(@client).to receive(:search_network_object).with(
          missing_object,
          ALGOSEC_SDK::NetworkObjectSearchType::EXACT
        ).and_return([])
        expect(@client).to receive(:create_network_object).with(
          missing_object_type, missing_object, missing_object
        ).and_return('created_object')
        expect(create_missing_objects).to eq ['created_object']
      end
      it 'creates the object if it was not found by exact name in the search results' do
        expect(@client).to receive(:search_network_object).with(
          missing_object,
          ALGOSEC_SDK::NetworkObjectSearchType::EXACT
        ).and_return([{ 'name' => 'some-other-name-for-the-object' }])
        expect(@client).to receive(:create_network_object).with(
          missing_object_type, missing_object, missing_object
        ).and_return('created_object')
        expect(create_missing_objects).to eq ['created_object']
      end
      it 'avoids object creation if it is found' do
        expect(@client).to receive(:search_network_object).with(anything, anything).and_return(
          [{ 'name' => missing_object }]
        )
        expect(@client).not_to receive(:create_network_object)
        expect(create_missing_objects).to eq []
      end
    end
    context 'when the missing object is an IP' do
      let(:missing_object) { '192.168.1.1' }
      let(:missing_object_type) { ALGOSEC_SDK::NetworkObjectType::HOST }
      it_behaves_like 'IP/CIDR/Range missing objects'
    end
    context 'when the missing object is a CIDR' do
      let(:missing_object) { '192.168.1.1/1' }
      let(:missing_object_type) { ALGOSEC_SDK::NetworkObjectType::RANGE }
      it_behaves_like 'IP/CIDR/Range missing objects'
    end
    context 'when the missing object is a Range' do
      let(:missing_object) { '192.168.1.1-192.168.2.2' }
      let(:missing_object_type) { ALGOSEC_SDK::NetworkObjectType::RANGE }
      it_behaves_like 'IP/CIDR/Range missing objects'
    end
    context 'when the missing object is neither IP/Range/CIDR' do
      let(:missing_object) { 'some-non-ip-object-name' }

      it 'does not search for it' do
        expect(@client).not_to receive(:search_network_object)
        create_missing_objects
      end
      it 'does not create it' do
        expect(@client).not_to receive(:create_network_object)
        create_missing_objects
      end
    end
    context 'when there is unexpected server error upon object creation' do
      let(:missing_object) { '192.168.1.1' }
      it 'raises an exception' do
        allow(@client).to receive(:search_network_object).and_return([])
        expect(@client).to receive(:create_network_object).and_raise(ALGOSEC_SDK::BadRequest, 'Unknown Error')
        expect { create_missing_objects }.to raise_error(ALGOSEC_SDK::BadRequest)
      end
    end
  end
  describe '#create_missing_services#' do
    it 'no error raised for already existing services' do
      service_name = 'tcp/50'
      already_exists_error = 'Service name already exists'
      expect(@client).to receive(:create_network_service).with(
        service_name, [%w[tcp 50]]
      ).and_raise(ALGOSEC_SDK::BadRequest, already_exists_error)
      created_services = @client.create_missing_services([service_name])
      expect(created_services).to eq([])
    end
    it 'create service and fail due to unknown exception from server' do
      service_name = 'tcp/50'
      exc = ALGOSEC_SDK::BadRequest.new
      expect(@client).to receive(:create_network_service).with(
        service_name, [%w[tcp 50]]
      ).and_raise(exc)
      expect do
        @client.create_missing_services([service_name])
      end.to raise_error(exc)
    end
    it 'only protocol/port object names are created' do
      service_name1 = 'tcp/50'
      service_name2 = 'someServiceName'
      fake_created_object = { name: service_name1 }
      expect(@client).to receive(:create_network_service).with(
        service_name1, [%w[tcp 50]]
      ).and_return(fake_created_object)
      created_objects = @client.create_missing_services([service_name1, service_name2])
      expect(created_objects).to eq([fake_created_object])
    end
    describe '#plan_application_flows#' do
      it 'There is nothing to change, new flows and flows on server are equal' do
        new_app_flows = server_app_flows = { 'flow1' => {}, 'flow2' => {}, 'flow3' => {} }
        expect(ALGOSEC_SDK::AreFlowsEqual).to receive(:flows_equal?).thrice.with({}, {}).and_return(true)

        flows_to_delete, flows_to_create, flows_to_modify = @client.plan_application_flows(
          server_app_flows,
          new_app_flows
        )
        expect(flows_to_delete).to eq(Set.new)
        expect(flows_to_create).to eq(Set.new)
        expect(flows_to_modify).to eq(Set.new)
      end
      it 'There are flows to delete, flows to create, and flows that have changed' do
        new_app_flows = { 'new-flow' => {}, 'modified-flow' => {} }
        server_app_flows = {
          'flow-that-will-be-deleted' => { flowID: 1 },
          'modified-flow' => { flowID: 2 }
        }
        expect(ALGOSEC_SDK::AreFlowsEqual).to receive(:flows_equal?).with(
          new_app_flows['modified-flow'], server_app_flows['modified-flow']
        ).and_return(false)

        flows_to_delete, flows_to_create, flows_to_modify = @client.plan_application_flows(
          server_app_flows,
          new_app_flows
        )
        expect(flows_to_delete).to eq(Set.new(%w[flow-that-will-be-deleted]))
        expect(flows_to_create).to eq(Set.new(%w[new-flow]))
        expect(flows_to_modify).to eq(Set.new(%w[modified-flow]))
      end
    end
    describe '#implement_app_flows_plan#' do
      it 'Application draft is applied when a flow is deleted' do
        app_name = 'AppName'
        fake_app_revision_id = 1500

        new_app_flows = { 'new-flow' => {}, 'modified-flow' => {} }
        server_app_flows = {
          'flow-that-will-be-deleted' => { 'flowID' => 1 },
          'modified-flow' => { 'flowID' => 2 }
        }
        flows_to_delete = Set.new(['flow-that-will-be-deleted'])
        flows_to_create = Set.new([])
        flows_to_modify = Set.new([])

        expect(@client).to receive(:get_app_revision_id_by_name).with(app_name).and_return(fake_app_revision_id)
        # App revision id is updated after a flow is deleted
        expect(@client).to receive(:get_app_revision_id_by_name).with(app_name).and_return(fake_app_revision_id + 1)
        expect(@client).to receive(:get_application_flows_hash).with(
          fake_app_revision_id + 1
        ).and_return(server_app_flows)
        expect(@client).to receive(:delete_flow_by_id).with(
          fake_app_revision_id,
          server_app_flows['flow-that-will-be-deleted']['flowID']
        )
        # Use the app revision id that was updated after deletion
        expect(@client).to receive(:apply_application_draft).with(fake_app_revision_id + 1)

        @client.implement_app_flows_plan(
          app_name,
          new_app_flows,
          server_app_flows,
          flows_to_delete,
          flows_to_create,
          flows_to_modify
        )
      end
      it 'Application draft is applied when a flow is created' do
        app_name = 'AppName'
        fake_app_revision_id = 1500

        new_app_flows = {
          'new-flow' => {
            'sources' => 'some-sources',
            'destinations' => 'some-destinations',
            'services' => 'some-services',
            'users' => 'some-users',
            'applications' => 'some-applications',
            'comment' => 'some-comment'
          }
        }
        server_app_flows = {}
        flows_to_delete = Set.new([])
        flows_to_create = Set.new(['new-flow'])
        flows_to_modify = Set.new([])

        expect(@client).to receive(:get_app_revision_id_by_name).with(app_name).and_return(fake_app_revision_id)
        # App revision id is updated after a flow is created
        expect(@client).to receive(:get_app_revision_id_by_name).with(app_name).and_return(fake_app_revision_id + 1)
        expect(@client).to receive(:create_application_flow).with(
          fake_app_revision_id,
          'new-flow',
          new_app_flows['new-flow']['sources'],
          new_app_flows['new-flow']['destinations'],
          new_app_flows['new-flow']['services'],
          new_app_flows['new-flow']['users'],
          new_app_flows['new-flow']['applications'],
          new_app_flows['new-flow']['comment']
        )
        expect(@client).to receive(:apply_application_draft).with(fake_app_revision_id + 1)

        @client.implement_app_flows_plan(
          app_name,
          new_app_flows,
          server_app_flows,
          flows_to_delete,
          flows_to_create,
          flows_to_modify
        )
      end
      it 'Application draft is not applied when there is no change' do
        app_name = 'AppName'
        fake_app_revision_id = 1500

        new_app_flows = {}
        server_app_flows = {}
        flows_to_modify = flows_to_create = flows_to_delete = Set.new([])

        expect(@client).to receive(:get_app_revision_id_by_name).with(app_name).and_return(fake_app_revision_id)
        expect(@client).to receive(:apply_application_draft).never

        @client.implement_app_flows_plan(
          app_name,
          new_app_flows,
          server_app_flows,
          flows_to_delete,
          flows_to_create,
          flows_to_modify
        )
      end
      it 'flows to modify, are being deleted and then created' do
        app_name = 'AppName'
        fake_app_revision_id = 1500

        new_app_flows = {
          'modified-flow' => {
            'sources' => 'some-sources',
            'destinations' => 'some-destinations',
            'services' => 'some-services',
            'users' => 'some-users',
            'applications' => 'some-applications',
            'comment' => 'some-comment'
          }
        }
        server_app_flows = {
          'flow-that-will-be-deleted' => { 'flowID' => 1 },
          'modified-flow' => { 'flowID' => 2 }
        }
        flows_to_delete = Set.new([])
        flows_to_create = Set.new([])
        flows_to_modify = Set.new(['modified-flow'])

        expect(@client).to receive(:get_app_revision_id_by_name).with(app_name).and_return(fake_app_revision_id)
        # App revision id is updated after a flow is deleted
        expect(@client).to receive(:get_app_revision_id_by_name).with(app_name).and_return(fake_app_revision_id + 1)
        expect(@client).to receive(:get_application_flows_hash).with(
          fake_app_revision_id + 1
        ).and_return(server_app_flows)
        expect(@client).to receive(:delete_flow_by_id).with(
          fake_app_revision_id,
          server_app_flows['modified-flow']['flowID']
        )

        expect(@client).to receive(:create_application_flow).with(
          fake_app_revision_id + 1,
          'modified-flow',
          new_app_flows['modified-flow']['sources'],
          new_app_flows['modified-flow']['destinations'],
          new_app_flows['modified-flow']['services'],
          new_app_flows['modified-flow']['users'],
          new_app_flows['modified-flow']['applications'],
          new_app_flows['modified-flow']['comment']
        )

        # Use the app revision id that was updated after deletion
        expect(@client).to receive(:apply_application_draft).with(fake_app_revision_id + 1)

        @client.implement_app_flows_plan(
          app_name,
          new_app_flows,
          server_app_flows,
          flows_to_delete,
          flows_to_create,
          flows_to_modify
        )
      end
      it 'after first flow deletion, the draft app flows are updated' do
        app_name = 'AppName'
        fake_app_revision_id = 1500

        new_app_flows = {
          'modified-flow' => {
            'sources' => 'some-sources',
            'destinations' => 'some-destinations',
            'services' => 'some-services',
            'users' => 'some-users',
            'applications' => 'some-applications',
            'comment' => 'some-comment'
          }
        }
        server_app_flows = { 'flow-that-will-be-deleted' => { 'flowID' => 1 } }
        # Server flow IDs change when a new application revision is created after first deletion
        draft_server_app_flows = { 'another-flow-that-will-be-deleted' => { 'flowID' => 456 } }
        flows_to_delete = Set.new(%w[flow-that-will-be-deleted another-flow-that-will-be-deleted])
        flows_to_create = Set.new([])
        flows_to_modify = Set.new([])

        expect(@client).to receive(:get_app_revision_id_by_name).with(app_name).and_return(fake_app_revision_id)
        # App revision id is updated after a flow is deleted
        expect(@client).to receive(:get_app_revision_id_by_name).with(app_name).and_return(fake_app_revision_id + 1)
        expect(@client).to receive(:get_application_flows_hash).with(
          fake_app_revision_id + 1
        ).and_return(draft_server_app_flows)
        expect(@client).to receive(:delete_flow_by_id).with(
          fake_app_revision_id,
          server_app_flows['flow-that-will-be-deleted']['flowID']
        )
        expect(@client).to receive(:delete_flow_by_id).with(
          fake_app_revision_id + 1,
          draft_server_app_flows['another-flow-that-will-be-deleted']['flowID']
        )

        # Use the app revision id that was updated after deletion
        expect(@client).to receive(:apply_application_draft).with(fake_app_revision_id + 1)

        @client.implement_app_flows_plan(
          app_name,
          new_app_flows,
          server_app_flows,
          flows_to_delete,
          flows_to_create,
          flows_to_modify
        )
      end
      describe '#define_application_flows#' do
        it 'plan, implement flows and return the current flows defined on the server' do
          app_name = 'AppName'
          fake_app_revision_id = 1500

          new_app_flows = { 'flow2' => {}, 'flow3' => {} }
          new_server_app_flows = {
            'flow2' => { 'flowID' => 2 },
            'flow3' => { 'flowID' => 3 }
          }
          flows_from_server = {
            'flow1' => { 'flowID' => 1, 'name' => 'flow1' },
            'flow2' => { 'flowID' => 2, 'name' => 'flow2' }
          }

          flows_to_delete = Set.new(['flow1'])
          flows_to_modify = Set.new(['flow2'])
          flows_to_create = Set.new(['flow3'])

          expect(@client).to receive(:get_app_revision_id_by_name).with(app_name).and_return(fake_app_revision_id)
          # App revision id is updated after a flow is deleted
          expect(@client).to receive(:get_app_revision_id_by_name).with(app_name).and_return(fake_app_revision_id + 1)

          expect(@client).to receive(:get_application_flows).with(
            fake_app_revision_id
          ).and_return([{ 'flowID' => 1, 'name' => 'flow1' }, { 'flowID' => 2, 'name' => 'flow2' }])
          expect(@client).to receive(:get_application_flows).with(
            fake_app_revision_id + 1
          ).and_return(new_server_app_flows)

          expect(@client).to receive(:plan_application_flows).with(
            flows_from_server, new_app_flows
          ).and_return([flows_to_delete, flows_to_create, flows_to_modify])

          expect(@client).to receive(:implement_app_flows_plan).with(
            app_name,
            new_app_flows,
            flows_from_server,
            flows_to_delete,
            flows_to_create,
            flows_to_modify
          )

          @client.define_application_flows(
            app_name,
            new_app_flows
          )
        end
      end
    end
  end
end
