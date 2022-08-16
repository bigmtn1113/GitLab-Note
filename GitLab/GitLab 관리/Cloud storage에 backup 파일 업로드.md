# Cloud storage에 backup 파일 업로드

<br>

## 사전 조건
- **[Amazon S3 사용](https://github.com/kva231/GitLab-Note/blob/master/GitLab/Amazon%20S3%20%EC%82%AC%EC%9A%A9.md)**

<hr>

## GitLab 설정 파일 수정 및 적용
### `/etc/gitlab/gitlab.rb` 파일 수정
```ruby
# 'use_iam_profile' => true. Access Key와 Secret Access Key 대신 IAM으로 S3 연결
# '<>' 부분은 버킷명 입력

gitlab_rails['backup_upload_connection'] = {'provider' => 'AWS', 'region' => 'ap-northeast-2', 'use_iam_profile' => true }
gitlab_rails['backup_upload_remote_directory'] = '<backups>'
```

### 변경 사항 적용
```bash
sudo gitlab-ctl reconfigure
```

<hr>

## 참고
- **원격(클라우드) 스토리지에 백업 업로드** - https://docs.gitlab.com/ee/raketasks/backup_gitlab.html#uploading-backups-to-a-remote-cloud-storage
