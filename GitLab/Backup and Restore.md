# Backup and Restore

### 구성 현황
- **GitLab 버전 - 최소 12.2**
- **Docker Container 내에서 GitLab 실행**

<hr>

## Backup
### 1. Backup 진행 및 확인
```bash
# Backup 파일 생성
docker exec -it <container name> gitlab-backup create

# ~_gitlab_backup.tar 파일 확인. Host에선 /srv/gitlab/data/backups
docker exec -it <container name> ls /var/opt/gitlab/backups
```

### 2. 구성 파일 확인
CI/CD 시크릿 변수, two-factor 인증 정보 등과 같은 정보들은 명령어로 자동으로 백업 되지 않으니 별도로 백업 진행해야 하나,  
Docker Container 내에서 GitLab을 실행 할 때 마운트를 진행했으므로 마운트한 경로(`/srv/gitlab/config`)에 자동으로 저장됨
```bash
# gitlab-secrets.json, gitlab.rb 확인. Host에선 /srv/gitlab/config
docker exec -it <container name> ls /etc/gitlab/
```

<hr>

## Restore
### 3. 프로세스 종료 후, Restore 진행
```bash
# 데이터베이스 연결 프로세스 종료
docker exec -it <container name> gitlab-ctl stop puma
docker exec -it <container name> gitlab-ctl stop sidekiq

# 진행하기 전, 프로세스들이 모두 종료 되었는지 확인
docker exec -it <container name> gitlab-ctl status

# Restore 진행
docker exec -it <container name> gitlab-backup restore BACKUP=<backup 파일 명에서 _gitlab_backup.tar를 제외하고 입력>
```

### 4. GitLab 재시작
```bash
# GitLab 컨테이너 재시작
docker restart <container name>

# GitLab 체크
docker exec -it <container name> gitlab-rake gitlab:check SANITIZE=true
```

<hr>

## ※ 로컬 파일의 backup lifetime 제한(이전 backups 정리)
정기적인 백업이 모든 디스크 공간을 사용하지 않도록 하려면 백업에 대해 제한된 수명 정책을 설정 필요  
다음 백업 작업이 실행될 때 `backup_keep_time`보다 오래된 백업 파일 정리하도록 수행

※ 이 옵션은 로컬 파일만 관리하므로, Amazon S3와 같은 객체 스토리지를 사용할 경우 적절한 보존 정책 구성 필요

### GitLab 설정 파일(`/etc/gitlab/gitlab.rb`) 파일 수정
```ruby
# Limit backup lifetime to 7 days - 604800 seconds
gitlab_rails['backup_keep_time'] = 604800
```

### GitLab 설정 파일 적용
```bash
sudo gitlab-ctl reconfigure
```

<hr>

## ※ Cloud storage에 backup 파일 업로드
### 사전 조건
- **[Amazon S3 사용](https://github.com/kva231/GitLab-Note/blob/master/GitLab/Amazon%20S3%20%EC%82%AC%EC%9A%A9.md)**

### GitLab 설정 파일(`/etc/gitlab/gitlab.rb`) 파일 수정
```ruby
# 'use_iam_profile' => true. Access Key와 Secret Access Key 대신 IAM으로 S3 연결
# '<>' 부분은 버킷명 입력

gitlab_rails['backup_upload_connection'] = {'provider' => 'AWS', 'region' => 'ap-northeast-2', 'use_iam_profile' => true }
gitlab_rails['backup_upload_remote_directory'] = '<backups>'
```

### GitLab 설정 파일 적용
```bash
sudo gitlab-ctl reconfigure
```

<hr>

## 참고
- **Backup** - https://docs.gitlab.com/ee/raketasks/backup_gitlab.html
- **Restore** - https://docs.gitlab.com/ee/raketasks/restore_gitlab.html
- **로컬 파일의 백업 수명 제한(이전 백업 정리)** - https://docs.gitlab.com/ee/raketasks/backup_gitlab.html#limit-backup-lifetime-for-local-files-prune-old-backups
- **원격(클라우드) 스토리지에 백업 업로드** - https://docs.gitlab.com/ee/raketasks/backup_gitlab.html#uploading-backups-to-a-remote-cloud-storage
- **Omnibus GitLab reconfigure** - https://docs.gitlab.com/ee/administration/restart_gitlab.html#omnibus-gitlab-reconfigure
