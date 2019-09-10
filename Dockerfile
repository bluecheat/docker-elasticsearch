# Copyright 2017 The Kubernetes Authors.
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

FROM golang:1.12.0 AS builder
COPY elasticsearch_logging_discovery.go go.mod go.sum /
RUN CGO_ENABLED=0 GOOS=linux GO111MODULE=on go build -a -ldflags "-w" -o /elasticsearch_logging_discovery /elasticsearch_logging_discovery.go

FROM docker.elastic.co/elasticsearch/elasticsearch:7.2.0

VOLUME ["/data"]
EXPOSE 9200 9300

COPY --from=builder /elasticsearch_logging_discovery bin/
COPY run.sh bin/
COPY config/elasticsearch.yml config/log4j2.properties config/

USER root

#Python3 설치
RUN yum install -y https://centos7.iuscommunity.org/ius-release.rpm
RUN yum install -y python36u python36u-libs python36u-devel python36u-pip

RUN unlink /bin/python && ln -s /bin/python3.6 /bin/python
RUN ln -s /bin/pip3.6 /bin/pip
RUN pip install elasticsearch-curator

RUN chown -R elasticsearch:elasticsearch ./
CMD ["bin/run.sh"]
