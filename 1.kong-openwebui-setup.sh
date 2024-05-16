#!/bin/bash

curl -i -X POST http://localhost:8001/upstreams -d "name=open-webui-upstream" -d "slots=1000"
curl -i -X POST http://localhost:8001/upstreams/open-webui-upstream/targets -d "target=open-webui:8080" -d "weight=100"
curl -i -X POST "http://localhost:8001/services/" -d "name=open-webui-service" -d "host=open-webui-upstream" -d "protocol=http" -d "port=0"
curl -i -X POST "http://localhost:8001/services/open-webui-service/routes" -d "name=open-webui-route" -d "paths[]=/"
curl -i -X POST "http://localhost:8001/services/open-webui-service/routes" -d "name=open-webui-route" -d "paths[]=/"

echo "Kong completed setup for Open WebUI"