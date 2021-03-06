# frozen_string_literal: true

# (c) Copyright 2018 AlgoSec Systems
#
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the specific
# language governing permissions and limitations under the License.

# Contains all the custom Exception classes
module ALGOSEC_SDK
  # Client configuration is invalid
  class InvalidClient < StandardError
  end

  # Could not make request
  class InvalidRequest < StandardError
  end

  # 400
  class BadRequest < StandardError
  end

  # 401
  class Unauthorized < StandardError
  end

  # 404
  class NotFound < StandardError
  end

  # Other bad response codes
  class RequestError < StandardError
  end
end
