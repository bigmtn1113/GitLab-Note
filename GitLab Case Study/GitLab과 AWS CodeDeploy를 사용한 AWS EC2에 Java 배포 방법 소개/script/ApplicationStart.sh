#!/usr/bin/env bash

JAR_FILE=test_project_codedeploy-0.0.1-SNAPSHOT.jar

cd /spring-boot-helloworld/
sudo nohup java -jar -Dserver.port=8080 ./$JAR_FILE >/dev/null 2>&1 &

sleep 10
