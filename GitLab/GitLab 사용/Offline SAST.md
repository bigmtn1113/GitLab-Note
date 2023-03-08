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
docker pull registry.gitlab.com/security-products/semgrep:3
```

### 2. GitLab Container Registry에 docker login
```bash
docker login registry.example.com
```

### 3. GitLab Container Registry로 push하기 위해 semgrep 이미지 tag 작성
```bash
docker tag registry.gitlab.com/security-products/semgrep:3 registry.example.com/project/semgrep:3
```

### 4. semgrep 이미지를 GitLab Container Registry에 push
```bash
docker push registry.example.com/project/semgrep:3
```

### 5. GitLab Container Registry에 semgrep 이미지가 업로드 되었는지 확인
1\) 상단 표시줄에서 **Main Menu**  
2\) **Projects** 선택 후 project 선택  
3\) 왼쪽 사이드바에서 **Packages and registries > Container Registry** 선택

### 6. [SAST.gitlab-ci.yml](https://gitlab.com/gitlab-org/gitlab/-/blob/master/lib/gitlab/ci/templates/Jobs/SAST.gitlab-ci.yml) 파일 local에 다운로드

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
- Container Registry 보기 - https://docs.gitlab.com/ee/user/packages/container_registry/index.html#view-the-container-registry
- Runner가 image를 pull하는 방법 구성 - https://docs.gitlab.com/runner/executors/docker.html#configure-how-runners-pull-images
