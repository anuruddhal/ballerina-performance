#!/bin/bash -e
# Copyright 2021 WSO2 Inc. (http://wso2.org)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# ----------------------------------------------------------------------------
# Installation script for the VM
# ----------------------------------------------------------------------------
set -e
if [ "$#" -ne 2 ]
then
  echo "First parameter should contain k8s cluster ip and second parameter should contain the sample folder name"
  exit 1
fi

echo "$1"
echo "$2"
sudo apt-get update && sudo apt-get install openjdk-8-jdk -y
echo "$1 perf.test.com" | sudo tee -a /etc/hosts
(cd /artifacts/scripts/; ./start-jmeter.sh -i /artifacts -d)
chmod -R 777 /artifacts
(cd /artifacts/tests/"${2}"/scripts/; ./run.sh "${2}")
(cd /artifacts/tests/"${2}"/results/; /artifacts/utils/jtl-splitter/jtl-splitter.sh -- -f /artifacts/tests/"${2}"/results/original.jtl -t 300 -u SECONDS -s)
ls -ltr /artifacts/tests/"${2}"/results/
(cd /artifacts/tests/"${2}"/results/; /artifacts/apache-jmeter-4.0/bin/JMeterPluginsCMD.sh --generate-csv summary.csv --input-jtl original-measurement.jtl --plugin-type AggregateReport)
