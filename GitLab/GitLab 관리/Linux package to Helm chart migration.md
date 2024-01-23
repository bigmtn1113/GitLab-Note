# Linux package to Helm chart migration

<br>

## 전제 조건
- Package 기반 GitLab instance가 반드시 실행 중이어야 하며, `gitlab-ctl status` 실행 후 `down` 표시가 된 서비스가 없는지 확인
- Git repository 무결성 확인 권장
- Package 기반 설치와 동일한 GitLab version을 실행하는 helm chart 기반 배포 필요
- Helm chart 기반 배포에서 사용할 객체 storage 설정 필요  
  Production 환경의 경우 외부 객체 storage 사용 권장

<br>

## Migration
### 1. Package 기반 설치에서 객체 storage로 기존 data를 migration

### 2. Backup tarball 생성
```bash
$ sudo gitlab-backup create
```

명시적으로 변경하지 않는 한 backup file은 `/var/opt/gitlab/backups`에 저장

### 3. Secrets부터 시작하여 package 기반 설치에서 Helm chart로 backup 복원
Linux package instance로부터 rails secret을 복원하려면, secrets은 `/etc/gitlab/gitlab-secrets.json` file에 JSON 형식으로 저장되므로
File을 YAML 형식으로 변환한 후 secret을 생성

#### 1\) `/etc/gitlab/gitlab-secrets.json` file을 `kubectl` 명령을 실행하는 workstation에 파일 복사

#### 2\) Workstation에 yq tool(4.21.1 이상 version) 설치

#### 3\) 다음 명령을 실행하여 `gitlab-secrets.json` file을 YAML 형식으로 변환

```bash
$ yq -P '{"production": .gitlab_rails}' gitlab-secrets.json >> gitlab-secrets.yaml
```

#### 4\) 새 `gitlab-secrets.yaml` file에 다음 내용이 있는지 확인

```yaml
production:
  db_key_base: <your key base value>
  secret_key_base: <your secret key base value>
  otp_key_base: <your otp key base value>
  openid_connect_signing_key: <your openid signing key>
  ci_jwt_signing_key: <your ci jwt signing key>
```

#### 5\) [Secrets 및 backup file 복원](https://github.com/bigmtn1113/GitLab-Note/blob/master/GitLab/GitLab%20%EA%B4%80%EB%A6%AC/Backup%20and%20restore/Helm%20chart%20(Kubernetes).md#restore)

### 4. 모든 pods을 다시 시작하여 변경사항이 적용되었는지 확인
```bash
$ kubectl delete pods -lrelease=<helm release name>
```

### 5. Package 기반 설치에 존재했던 projects, groups, users, issues 등이 복원되었는지 확인
또한 uploade된 files(avatars, issues에 upload된 files 등)가 잘 load되는지 확인

<hr>

## 참고
- **Linux package에서 Helm chart로 migration** - https://docs.gitlab.com/charts/installation/migration/package_to_helm.html
- **GitLab 설치 복원** - https://docs.gitlab.com/charts/backup-restore/restore.html
