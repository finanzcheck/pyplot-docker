# Copyright 2016 The Kubernetes Authors All rights reserved.
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

all: docker push plot

PLOTTER_DOCKER_IMAGE       := valdemon/netperf-plotperf:latest

Y_RANGE ?= 45000
SUFFIX ?= netperf-latest
TESTCASE ?= netperf-latest
INPUT_CSV ?= $(SUFFIX).csv
INPUT_DIR ?= .

docker:
	mkdir -p Dockerbuild && \
	cp -f Dockerfile Dockerbuild/ && \
	cp -f plotperf.py Dockerbuild/ &&\
	docker build -t $(PLOTTER_DOCKER_IMAGE) Dockerbuild/

push: docker
	gcloud docker push $(PLOTTER_DOCKER_IMAGE)

clean:
	@rm -f Dockerbuild/*

# Use this target 'plot' to run the docker container that will pick up $(INPUT_CSV) and render it into png and svg images
plot: $(INPUT_DIR)/$(INPUT_CSV)
	mkdir -p tmp && cp $(INPUT_DIR)/$(INPUT_CSV) tmp/ &&\
	docker run --detach=false -v `pwd`/tmp:/plotdata $(PLOTTER_DOCKER_IMAGE) --csv /plotdata/$(INPUT_CSV) --suffix $(SUFFIX) -y $(Y_RANGE) -t $(TESTCASE) &&\
	cp tmp/* .
