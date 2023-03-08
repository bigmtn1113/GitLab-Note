# Offline SAST

<br>

인터넷을 통한 외부 리소스에 대한 액세스가 제한적인 환경의 self-managed GitLab 인스턴스의 경우 SAST 작업을 성공적으로 실행하려면 일부 조정 필요

<br>

## 요구 사항
- executor가 `docker` 또는 `kubernetes`인 GitLab runner
- 로컬로 사용 가능한 SAST analyzer 이미지의 사본이 있는 Docker Container Registry

<br>



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
