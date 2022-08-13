# GitLab Runner 등록

<br>

## 요구 사항
- **GitLab이 설치된 서버와 별도의 서버에 설치**
- **토큰 얻기**
  - **shared runner** - 관리자가 GitLab Admin Area으로 이동 후, **Overview > Runners** 클릭
  - **group runner** - **group 선택 > Settings > CI/CD**로 이동 후, Runners 섹션 확장
  - **project-specific runner** - **project 선택 > Settings > CI/CD**로 이동 후, Runners 섹션 확장

<br>

## 전제 조건
- docker를 이용해 컨테이너에 GitLab Runner 설치

<hr>

## Runner 등록 및 확인
GitLab Runner 컨테이너 접속 후, 진행

### 등록
```bash
gitlab-runner register

Enter the GitLab instance URL (for example, https://gitlab.com/):
Enter the registration token:
Enter a description for the runner:
Enter tags for the runner (comma-separated):
Enter optional maintenance note for the runner:
Enter an executor: docker-ssh+machine, kubernetes, custom, docker-ssh, parallels, ssh, docker, shell, virtualbox, docker+machine:
Enter the default Docker image (for example, ruby:2.7):
```
- GitLab 인스턴스 URL 입력
- 러너 등록을 위해 획득한 토큰 입력
- 러너에 대한 설명 입력. 추후 변경 가능
- 러너와 연결된 태그를 쉼표로 구분하여 입력. 추후 변경 가능
- 러너에 대한 선택적 유지 관리 메모 입력
- 무엇으로 빌드를 실행할 것인지 실행자 입력. docker가 일반적
- 실행자를 docker로 입력한 경우, `.gitlab-ci.yml`에 기본 이미지를 정의하지 않은 프로젝트에서 사용할 기본 이미지 입력

### 확인
#### 컨테이너에서 확인
```bash
gutkab-runner list
```

#### Web에서 확인
토큰 얻었던 경로로 가서 사용 가능한 러너 확인

<hr>

## 참고
- **Runner 등록** - https://docs.gitlab.com/runner/register/
