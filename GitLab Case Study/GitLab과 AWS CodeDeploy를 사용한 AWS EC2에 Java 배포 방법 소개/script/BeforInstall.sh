#!/usr/bin/env bash

sudo mkdir -vp /spring-boot-helloworld/release

TM=$(date +%F_%T)

# 이전에 실행되었던 jar 파일을 백업 
if [ -e /spring-boot-helloworld/*.jar ]; then
    mv /spring-boot-helloworld/*.jar /spring-boot-helloworld/$TM.jar
fi
