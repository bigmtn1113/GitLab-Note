# 로컬 파일의 backup lifetime 제한(이전 backups 정리)

정기적인 백업이 모든 디스크 공간을 사용하지 않도록 하려면 백업에 대해 제한된 수명 정책을 설정 필요  
다음 백업 작업이 실행될 때 `backup_keep_time`보다 오래된 백업 파일 정리하도록 수행

※ 이 옵션은 로컬 파일만 관리하므로, Amazon S3와 같은 객체 스토리지를 사용할 경우 적절한 보존 정책 구성 필요

<hr>

## GitLab 설정 파일 수정 및 적용
### `/etc/gitlab/gitlab.rb` 파일 수정
```ruby
# Limit backup lifetime to 7 days - 604800 seconds
gitlab_rails['backup_keep_time'] = 604800
```

### 변경 사항 적용
```bash
sudo gitlab-ctl reconfigure
```

<hr>

## 참고
- **로컬 파일의 백업 수명 제한(이전 백업 정리)** - https://docs.gitlab.com/ee/raketasks/backup_gitlab.html#limit-backup-lifetime-for-local-files-prune-old-backups
