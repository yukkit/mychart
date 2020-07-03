################################################################################
#  Licensed to the Apache Software Foundation (ASF) under one
#  or more contributor license agreements.  See the NOTICE file
#  distributed with this work for additional information
#  regarding copyright ownership.  The ASF licenses this file
#  to you under the Apache License, Version 2.0 (the
#  "License"); you may not use this file except in compliance
#  with the License.  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
# limitations under the License.
################################################################################


# This file defines the default environment for Flink's SQL Client.
# Defaults might be overwritten by a session specific environment.


# See the Table API & SQL documentation for details about supported properties.


#==============================================================================
# Table Sources
#==============================================================================

# Define table sources and sinks here.

tables: [] # empty list
# A typical table source definition looks like:
# - name: ...
#   type: source
#   connector: ...
#   format: ...
#   schema: ...

#==============================================================================
# User-defined functions
#==============================================================================

# Define scalar, aggregate, or table functions here.

functions: [] # empty list
# A typical function definition looks like:
# - name: ...
#   from: class
#   class: ...
#   constructor: ...

#==============================================================================
# Execution properties
#==============================================================================

# Execution properties allow for changing the behavior of a table program.

execution:
  # 'batch' or 'streaming' execution
  type: streaming
  # allow 'event-time' or only 'processing-time' in sources
  time-characteristic: event-time
  # interval in ms for emitting periodic watermarks
  periodic-watermarks-interval: 200
  # 'changelog' or 'table' presentation of results
  result-mode: table
  # parallelism of the program
  parallelism: 1
  # maximum parallelism
  max-parallelism: 128
  # minimum idle state retention in ms
  min-idle-state-retention: 0
  # maximum idle state retention in ms
  max-idle-state-retention: 0
  # maximum number of result rows
  max-table-result-rows: 1000
  # controls how table programs are restarted in case of a failures
  restart-strategy:
    # strategy type
    # possible values are "fixed-delay", "failure-rate", "none", or "fallback" (default)
    type: fixed-delay
    attempts: 5
    delay: 10000
  # Configuration that captures all checkpointing related settings.
  checkpoint:
    enabled: true
    # possible values are "exactly_once" "at_least_once"
    mode: exactly_once
    # Time interval between state checkpoints in milliseconds.
    interval: 5000
  ldb-server-url: http://node:port
  ldb-server-token: ldb-worker
  ml:
    # number of Predicted data bulk size
    batch-size: 1
    # Time delay in milliseconds
    wait-delay: 100
  internal-source:
    fetch-size: 1000
  internal-sink:
    batch-size: 1000
#==============================================================================
# Deployment properties
#==============================================================================

# Deployment properties allow for describing the cluster to which table
# programs are submitted to.

deployment:
  # general cluster communication timeout in ms
  response-timeout: 5000
  # (optional) address from cluster to gateway
  gateway-address: ""
  # (optional) port from cluster to gateway.a port number that is automatically allocated: "0",
  # a range of ports: "50100-50200", or a list of ranges and ports: "50100-50200,50300-50400,51234"
  gateway-port: 0


