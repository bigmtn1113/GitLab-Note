# GitLab Runner 설치 및 실행

<br>

## ※ GitLab Runner란?
`.gitlab-ci.yml` 파일에 나열된 명령을 실행하고 그 결과를 GitLab 자체에 다시 보고하여 GitLab의 그래픽 인터페이스에 보여주는 서버

<br>

## ※ 설치 위치
GitLab을 설치하려는 동일한 머신에 GitLab Runner를 설치하지 않는 것이 권장 사항  
GitLab Runner를 구성하는 방법과 CI 환경에서 애플리케이션을 실행하는 데 사용하는 도구에 따라, GitLab Runner는 상당한 양의 가용 메모리를 사용할 수 있음

<hr>

## 전제 조건
- **docker 설치**

<br>

## 로컬 시스템 볼륨 마운트를 사용하여 Runner 컨테이너 시작
Docker 컨테이너 내에서 gitlab-runner를 실행하려면 컨테이너를 다시 시작할 때 구성이 손실되지 않도록 해야 함

```bash
docker run -d --name gitlab-runner --restart always \
-v /srv/gitlab-runner/config:/etc/gitlab-runner \
-v /var/run/docker.sock:/var/run/docker.sock \
gitlab/gitlab-runner:latest
```

<br>

## Upgrade version
기존 마운트 경로 확인 후, 진행
```bash
docker inspect gitlab-runner
```

### 1. 실행중인 컨테이너 중지 및 제거
```bash
docker stop gitlab-runner && docker rm gitlab-runner
```

### 2. GitLab Runner 컨테이너 시작
기존 마운트 경로와 동일한 경로 사용 필수
```bash
docker run -d --name gitlab-runner --restart always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /srv/gitlab-runner/config:/etc/gitlab-runner \
  gitlab/gitlab-runner:latest
```

<hr>

## 참고
- **컨테이너에서 GitLab Runner 실행** - https://docs.gitlab.com/runner/install/docker.html#install-the-docker-image-and-start-the-container
- **GitLab Runner Upgrade** - https://docs.gitlab.com/runner/install/docker.html#upgrade-version
