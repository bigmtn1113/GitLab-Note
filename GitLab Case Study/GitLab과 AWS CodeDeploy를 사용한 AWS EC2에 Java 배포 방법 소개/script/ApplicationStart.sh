#!/usr/bin/env bash

cd /spring-boot-helloworld/
sudo nohup java -jar -Dserver.port=8080 ./*.jar >/dev/null 2>&1 &

sleep 10