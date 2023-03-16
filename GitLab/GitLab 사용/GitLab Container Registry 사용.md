# GitLab Container Registry 사용

<br>

통합 Container Registry를 사용하여 각 GitLab 프로젝트의 컨테이너 이미지 저장 가능  
GitLab Container Registry 활성화 후 진행

<br>

## Container images naming 규칙
```bash
<registry URL>/<namespace>/<project>/<image>
```

만약 project가 `<GitLab URL>/mynamespace/myproject`라면 container image는 `<registry URL>/mynamespace/myproject`여야 하며 container image 이름 끝에 최대 two levels deep까지 이름 추가 가능

#### Example
```bash
registry.example.com/mynamespace/myproject:some-tag
registry.example.com/mynamespace/myproject/image:latest
registry.example.com/mynamespace/myproject/my/image:rc1
```

<br>

## Container Registry 인증
Container Registry 인증 토큰
- Personal access token
- Deploy token
- Project access token
- Group access token

토큰은 다음과 같은 최소 scope 필요  
- Read(pull) access를 위해선 `read_registry`
- Write(push) access를 위해선 `write_registry` and `read_registry`

Doker login  
```bash
docker login -u <username> -p <token> registry.example.com
```

### GitLab CI/CD를 사용한 인증
- **`CI_REGISTRY_USER` CI/CD 변수**
  
  Read-write 권한으로 Container Registry에 접근 가능하며 하나의 job에서만 유효  
  Password는 자동으로 만들어져 `CI_REGISTRY_PASSWORD`에 할당됨
  
  ```bash
  docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  ```
- **CI JOB TOKEN**
  
  ```bash
  docker login -u $CI_REGISTRY_USER -p $CI_JOB_TOKEN $CI_REGISTRY
  ```
- **Deploy token**
  
  다음과 같은 최소 scope 필요  
  - Read(pull) access를 위해선 `read_registry`
  - Write(push) access를 위해선 `write_registry`
  
  ```bash
  docker login -u $CI_DEPLOY_USER -p $CI_DEPLOY_PASSWORD $CI_REGISTRY
  ```
- **Personal access token**
  
  다음과 같은 최소 scope 필요  
  - Read(pull) access를 위해선 `read_registry`
  - Write(push) access를 위해선 `write_registry`
  
  ```bash
  docker login -u <username> -p <access_token> $CI_REGISTRY
  ```

<br>

## Container image build 및 Container Registry push
컨테이너 이미지를 빌드하고 푸시하려면 먼저 Container Registry로 인증 필요

### Docker commands 사용
1. Container Registry 인증
2. Build 및 push
  ```bash
  docker build -t registry.example.com/group/project/image .
  docker push registry.example.com/group/project/image
  ```

### GitLab CI/CD에서 Container Registry 사용
GitLab CI/CD를 사용하여 container images를 build하고 Container Registry에 push 가능  
[Docker-in-Docker 설정](https://github.com/bigmtn1113/GitLab-Note/blob/master/GitLab/GitLab%20%EC%82%AC%EC%9A%A9/GitLab%20Container%20Registry%20%EC%82%AC%EC%9A%A9.md#-docker-executor%EC%97%90%EC%84%9C-tls%EA%B0%80-%ED%99%9C%EC%84%B1%ED%99%94%EB%90%9C-docker-in-docker-%EC%82%AC%EC%9A%A9) 후 진행

`.gitlab-ci.yml`  
```yaml
stages:
  - build

variables:
  DOCKER_TLS_CERTDIR: "/certs"

build:
  image: docker:20.10.16
  stage: build
  services:
    - docker:20.10.16-dind
  variables:
    IMAGE_TAG: $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG
  script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker build -t $IMAGE_TAG .
    - docker push $IMAGE_TAG
```

- `$CI_REGISTRY_IMAGE`는 project에 연결된 Container Registry 주소
- `CI_COMMIT_REF_NAME`은 project가 빌드되는 branch나 tag 이름인데 image tag엔 /를 포함할 수 없으므로 `CI_COMMIT_REF_SLUG` 사용

<br>

## ※ Docker executor에서 TLS가 활성화된 Docker-in-Docker 사용  
호스트 액세스는 잠재적인 보안 이슈므로 TLS 활성화는 권장사항  
Docker 19.03.12 이상부터 TLS가 default

- Docker-in-Docker를 사용하기 위해 `privileged` mode 활성화
- Docker client가 docker 인증서 파일를 사용할 수 있도록 `/certs/client` 마운트

`config.toml`
```toml
[[runners]]
  url = "https://gitlab.com/"
  token = TOKEN
  executor = "docker"
  [runners.docker]
    tls_verify = false
    image = "docker:20.10.16"
    privileged = true
    disable_cache = false
    volumes = ["/certs/client", "/cache"]
  [runners.cache]
    [runners.cache.s3]
    [runners.cache.gcs]
```

#### TLS 비활성화가 필요할 경우 다음과 같이 설정  
`config.oml`  
```toml
...
    volumes = ["/cache"]
...
```
`.gitlab-ci.yml`  
```yaml
...
variables:
  DOCKER_HOST: tcp://docker:2375
  DOCKER_TLS_CERTDIR: ""
...
```

<hr>

## 참고
- **Container images naming 규칙** - https://docs.gitlab.com/ee/user/packages/container_registry/#naming-convention-for-your-container-images
- **Container Registry 인증** - https://docs.gitlab.com/ee/user/packages/container_registry/authenticate_with_container_registry.html
- **Build and push images** - https://docs.gitlab.com/ee/user/packages/container_registry/build_and_push_images.html
- **Docker-in-Docker 사용** - https://docs.gitlab.com/ee/ci/docker/using_docker_build.html#use-docker-in-docker
