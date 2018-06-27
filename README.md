# Ruby SDK for AlgoSec Services

[![Build Status](https://travis-ci.org/algosec/algosec-ruby.svg)](https://travis-ci.org/algosec/algosec-ruby)
[![Gem Version](https://badge.fury.io/rb/algosec-sdk.svg)](https://badge.fury.io/rb/algosec-sdk)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://www.rubydoc.info/gems/algosec-sdk)

Software Development Kit for interacting with the AlgoSec services API.

## Installation

- Require the gem in your Gemfile:

  ```ruby
  gem 'algosec-sdk'
  ```

  Then run `$ bundle install`
- Or run the command:

  ```bash
  $ gem install algosec-sdk
  ```


## Client

Everything you do with this API happens through a client object.
Creating the client object is the first step; then you can perform actions on the client.

```ruby
require 'algosec-sdk'
client = ALGOSEC_SDK::Client.new(
  host: 'https://local.algosec.com',
  user: 'admin',              # This is the default
  password: 'algosec',
  ssl_enabled: false,                  # This is the default and strongly encouraged
  logger: Logger.new(STDOUT),         # This is the default
  log_level: :info,                   # This is the default
  disable_proxy: true                 # Default is false. Set to disable, even if ENV['http_proxy'] is set
)
client.login
```

:lock: Tip: Check the file permissions when storing passwords in clear-text.

#### Environment Variables

You can also set many client options using environment variables. For bash:

```bash
export ALGOSEC_HOST='https://oneview.example.com'
export ALGOSEC_USER='admin'
export ALGOSEC_PASSWORD='secret123'
export ALGOSEC_SSL_ENABLED=false # NOTE: Disabling SSL is strongly discouraged.
```

:lock: Tip: Be sure nobody can access to your environment variables

### Custom logging

The default logger is a standard logger to STDOUT, but if you want to specify your own, you can.  However, your logger must implement the following methods:

```ruby
debug(String)
info(String)
warn(String)
error(String)
level=(symbol, etc.) # The parameter here will be the log_level attribute
```


## Actions

Actions are performed on the client, and defined in the [helper modules](lib/algosec-sdk/helpers).

#### Business Flow

```ruby
# Get list of application flows for an application revision id
client.get_application_flows(app_revision_id)

# Delete a specific flow
client.delete_flow_by_id(app_revision_id, flow_id)

# Get connectivity status for a flow
client.get_flow_connectivity(app_revision_id, flow_id)

# Create a flow
client.create_application_flow(
      app_revision_id,
      flow_name,
      sources,
      destinations,
      network_users,
      network_apps,
      network_services,
      comment,
    )

# Fetch an application flow by it's name
client.get_application_flow_by_name(app_revision_id, flow_name)

# Get latest application revision id by application name
client.get_app_revision_id_by_name(app_name)

# Apply application draft
client.apply_application_draft(app_revision_id)

# Create a new network service
client.create_network_service(service_name, content)

# Create a new network object
client.create_network_object(type, content, name)

# defining the complete list of flows for a given app
flows = client.define_application_flows(
  'TEST',
  [
    'flow1' => {
      'sources' => ['HR Payroll server', '192.168.0.0/16'],
      'destinations' => ['16.47.71.62'],
      'services' => ['HTTPS']
    },
    'flow2' => {
      'sources' => ['10.0.0.1'],
      'destinations' => ['10.0.0.2'],
      'services' => ['udp/501']
    },
    'flow3' => {
      'sources' => ['1.2.3.4'],
      'destinations' => ['3.4.5.6'],
      'services' => ['SSH']
    }
  ]
)

```

## Custom requests

This gem includes some useful helper methods, but sometimes you need to make your own custom requests to the AlgoSec.
This project makes it extremely easy to do with some built-in methods for the client object. Here are some examples:

```ruby
# Get the application object:
response = client.rest_api(:get, '/BusinessFlow/rest/v1/applications/name/applicationName')
# or even more simple:
response = client.rest_get('/BusinessFlow/rest/v1/applications/name/applicationName')


# Then we can validate the response and convert the response body into a hash...
data = client.response_handler(response)

# For creating new BusinessFlow resources, use post:
options = { some: 'Data' }
response = client.rest_post('/BusinessFlow/rest/v1/exampleURL', body: options)
```

These example are about as basic as it gets, but you can make any type of AlgoSec API request.
If a helper does not do what you need, this will allow you to do it.
Please refer to the documentation and [code](lib/algosec-sdk/rest.rb) for complete list of methods and information about how to use them.


## License

This project is licensed under the Apache 2.0 license. Please see [LICENSE](LICENSE) for more info.


## Contributing and feature requests

**Contributing:** You know the drill. Fork it, branch it, change it, commit it, and pull-request it.
We are passionate about improving this project, and glad to accept help to make it better. However, keep the following in mind:

 - All pull requests must contain complete test code also. See the testing section below.
 - We reserve the right to reject changes that we feel do not fit the scope of this project, so for feature additions, please open an issue to discuss your ideas before doing the work.

**Feature Requests:** If you have a need that is not met by the current implementation, please let us know (via a new issue).
This feedback is crucial for us to deliver a useful product. Do not assume we have already thought of everything, because we assure you that is not the case.

### Building the Gem

First run `$ bundle` (requires the bundler gem), then...
 - To build only, run `$ rake build`.
 - To build and install the gem, run `$ rake install`.

### Use Gem from sourcecode

Run `pry -Ilib` then follow the README examples above. (don't forget to `require` the Gem)

### Testing

 - RuboCop: `$ rake rubocop`
 - Unit: `$ rake spec`
 - All test: `$ rake test`

Note: run `$ rake -T` to get a list of all the available rake tasks.

## Authors

 - AlmogCohen - [@AlmogCohen](https://github.com/AlmogCohen)
