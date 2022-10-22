#!/usr/bin/env bash

sudo mkdir -vp /spring-boot-helloworld/release

JAR_FILE=test_project_codedeploy-0.0.1-SNAPSHOT.jar
TM=$(date +%F_%T)

# 이전에 실행되었던 jar 파일을 백업 
if [ -e /spring-boot-helloworld/$JAR_FILE ]; then
    mv /spring-boot-helloworld/$JAR_FILE /spring-boot-helloworld/$TM.jar
fi
