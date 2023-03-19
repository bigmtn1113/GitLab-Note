# Offline SAST

<br>

인터넷을 통한 외부 리소스에 대한 액세스가 제한적인 환경의 self-managed GitLab 인스턴스의 경우 SAST 작업을 성공적으로 실행하려면 일부 조정 필요

<br>

## 요구 사항
- executor가 `docker` 또는 `kubernetes`인 GitLab runner
- 로컬로 사용 가능한 SAST analyzer 이미지의 사본이 있는 Docker Container Registry

<br>

## 사전 작업
GitLab SAST analyzer images 중 semgrep:3 사용

### 1. semgrep 이미지를 local에 pull
```bash
$ docker pull registry.gitlab.com/security-products/semgrep:3
```

※ 인터넷 access가 불가할 경우 외부에서 local로 이미지 이동

### 2. Docker Registry 실행 및 login
GitLab runner가 실행 중인 서버에서 진행

```bash
$ docker run -d -p 5000:5000 --name registry registry:2
$ docker login
```

### 3. Docker Registry로 push하기 위해 semgrep 이미지 tag 작성
```bash
$ docker tag registry.gitlab.com/security-products/semgrep:3 localhost:5000/semgrep:3
```

### 4. semgrep 이미지를 Docker Registry에 push
```bash
$ docker push localhost:5000/semgrep:3
```

### 5. [SAST.gitlab-ci.yml](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/SAST.gitlab-ci.yml) 파일 local에 다운로드 후 GitLab repository에 업로드

<br>

## Repository 구성
- `.gitlab-ci.yml`
- `SAST.gitlab-ci.yml`
- `test.py`

### `.gitlab-ci.yml`
```yaml
stages:
  - build
  - test

build-job:
  stage: build
  script:
    - echo "Test build-job"

include:
  - local: SAST.gitlab-ci.yml
```

`local` 옵션으로 registry.gitlab.com에 있는 template이 아닌 현재 repository에 있는 `SAST.gitlab-ci.yml` 파일 사용

### `SAST.gitlab-ci.yml`
```yaml
# Read more about this feature here: https://docs.gitlab.com/ee/user/application_security/sast/
#
# Configure SAST with CI/CD variables (https://docs.gitlab.com/ee/ci/variables/index.html).
# List of available variables: https://docs.gitlab.com/ee/user/application_security/sast/index.html#available-variables

variables:
  # Setting this variable will affect all Security templates
  # (SAST, Dependency Scanning, ...)
  SECURE_ANALYZERS_PREFIX: "localost:5000"
...
```

Registry 주소를 localhost로 설정  
semgrep-sast job이 이 변수를 참고하여 images 접근

- **registry.gitlab.com 접근할 경우**
  
  ![image](https://user-images.githubusercontent.com/46125158/226167277-9cfad232-55cf-4eb1-9e54-e2708f7426c3.png)
- **localhost로 접근할 경우**
  
  ![image](https://user-images.githubusercontent.com/46125158/226167454-e766c976-198b-4e08-847d-9f517a48b421.png)

### `test.py`
semgrep-sast job이 실행되기 위한 조건을 충족시키기 위해 테스트 용으로 생성  
다른 형식(`.js`, `.c`, `.go`, `.java` 등)의 파일 사용 가능

`SAST.gitlab-ci.yml`
```yaml
...
semgrep-sast:
  ...
  rules:
    - if: $SAST_DISABLED
      when: never
    - if: $SAST_EXCLUDED_ANALYZERS =~ /semgrep/
      when: never
    - if: $CI_COMMIT_BRANCH
      exists:
        - '**/*.py'
        - '**/*.js'
        - '**/*.jsx'
        - '**/*.ts'
        - '**/*.tsx'
        - '**/*.c'
        - '**/*.go'
        - '**/*.java'
        - '**/*.cs'
        - '**/*.html'
        - '**/*.scala'
        - '**/*.sc'
  ...
```

<br>

## ※ pull_policy
GitLab Runner의 default `pull_policy`은 `always`

- `always`: Local 이미지가 있어도 registry에서 이미지를 pull. Default
- `if-not-present`: Local 이미지가 없으면 registry에서 이미지를 pull
- `never`: Local 이미지만 사용

### 설정 방법
`/etc/gitlab-runner/config.toml` 파일 수정

```toml
[[runners]]
  (...)
  executor = "docker"
  [runners.docker]
    (...)
    pull_policy = "always" # available: always, if-not-present, never
```

Offline 환경이 아닌 경우, CI/CD pipelines에서 업데이트된 scanners를 사용할 수 있도록 `pull_policy` 설정을 `always`로 유지하는 것을 권장

<hr>

## 참고
- Offline 환경에서 SAST 작동 - https://docs.gitlab.com/ee/user/application_security/sast/#running-sast-in-an-offline-environment
- Runner가 image를 pull하는 방법 구성 - https://docs.gitlab.com/runner/executors/docker.html#configure-how-runners-pull-images
