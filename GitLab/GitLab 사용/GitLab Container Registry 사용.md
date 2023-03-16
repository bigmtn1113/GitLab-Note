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

<hr>

## 참고
- **Container images naming 규칙** - https://docs.gitlab.com/ee/user/packages/container_registry/#naming-convention-for-your-container-images
- **Container Registry 인증** - https://docs.gitlab.com/ee/user/packages/container_registry/authenticate_with_container_registry.html
