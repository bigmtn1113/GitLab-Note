#!/usr/bin/env bash

# CodeDeploy로 배포된 파일의 권한 변경 
sudo chown -R ec2-user. /spring-boot-helloworld/release

# jar 파일을 배포 
sudo rsync --delete-before --verbose --archive  /spring-boot-helloworld/release/*.jar /spring-boot-helloworld/ #> /var/log/deploy.log