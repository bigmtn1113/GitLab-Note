#!/usr/bin/env bash

TM=$(date +%F_%T)

# 이전에 실행되었던 jar 파일을 백업 
# mv /spring-boot-helloworld/*.jar /spring-boot-helloworld/$TM.jar