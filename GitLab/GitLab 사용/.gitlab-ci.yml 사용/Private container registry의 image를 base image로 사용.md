# Private container registry의 image를 base image로 사용

<br>

Base image를 private container registry에서 pull해서 사용 가능.

<br>

## Statically-defined credentials 사용
Private registry에 access하기 위해 취할 수 있는 접근 방식에는 두 가지가 존재.  
둘 다 적절한 인증 정보를 사용하여 CI/CD 변수인 `DOCKER_AUTH_CONFIG` 설정 필요.

- Per-job: Private registry에 access하도록 하나의 job을 구성하려면, `DOCKER_AUTH_CONFIG`를 CI/CD 변수로 추가.
- Per-runner: 모든 jobs가 private registry에 access할 수 있도록 runner를 구성하려면, runner 구성에서 `DOCKER_AUTH_CONFIG`를 환경 변수를 추가.

해당 page에서는 Per-job만 명시.

<br>

### `DOCKER_AUTH_CONFIG`
Private image를 사용하기 위해선, private container registry에 login 필요.

Private container registry 정보는 다음과 같이 가정:  
Key | Value
:---: | :---:
registry | registry.example.com:5000
username | bigmtn1113
password | 1234

<br>

1. Local machine에서 `docker login`:

   ```
   docker login registry.example.com:5000 --username bigmtn1113 --password 1234
   ```

   그 후, `~/.docker/config.json`의 내용 복사.

   더 이상 registry로 접근할 필요가 없으면, `docker logout`:

   ```
   docker logout registry.example.com:5000
   ```

2. Docker configuration file(`~/.docker/config.json`)의 내용을 값으로, CI/CD 변수인 `DOCKER_AUTH_CONFIG` 생성:

   ```json
   {
       "auths": {
           "registry.example.com:5000": {
               "auth": "bXlfdXNlcm5hbWU6bXlfcGFzc3dvcmQ="
           }
       }
   }
   ```

3. `.gitlab-ci.yml`의 `image` 또는 `services`에 정의된 `registry.example.com:5000`의 private image 사용 가능:

   ```yml
   build-job:
       stage: build
       image: registry.example.com:5000/namespace/image:tag
       script:
           - echo "build"
   ```

<hr>

## 참고
- **Private container registry의 image 접근** - https://docs.gitlab.com/ee/ci/docker/using_docker_images.html#access-an-image-from-a-private-container-registry
