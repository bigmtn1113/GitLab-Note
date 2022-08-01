# Amazon S3 사용

### 구성 현황
- **GitLab EC2에 S3 권한(PutObject, GetObject, DeleteObject)이 들어있는 Role 할당**
- **Docker Container 내에서 GitLab 실행**

<hr>

## GitLab 설정 파일 수정 및 적용
### `/etc/gitlab/gitlab.rb`
```ruby
gitlab_rails['object_store']['enabled'] = true
gitlab_rails['object_store']['proxy_download'] = true
gitlab_rails['object_store']['connection'] = {'provider' => 'AWS', 'region' => 'ap-northeast-2', 'use_iam_profile' => true }

gitlab_rails['object_store']['objects']['artifacts']['bucket'] = '<artifacts>'
gitlab_rails['object_store']['objects']['external_diffs']['bucket'] = '<external-diffs>'
gitlab_rails['object_store']['objects']['lfs']['bucket'] = '<lfs-objects>'
gitlab_rails['object_store']['objects']['uploads']['bucket'] = '<uploads>'
gitlab_rails['object_store']['objects']['packages']['bucket'] = '<packages>'
gitlab_rails['object_store']['objects']['dependency_proxy']['bucket'] = '<dependency-proxy>'
gitlab_rails['object_store']['objects']['terraform_state']['bucket'] = '<terraform-state>'
gitlab_rails['object_store']['objects']['pages']['bucket'] = '<pages>'
```
※ Access Key와 Secret Access Key 대신 IAM으로 S3 연결  
※ '<>' 부분은 버킷명 입력

### GitLab 설정 파일 적용
```bash
sudo gitlab-ctl reconfigure
```

<hr>

## 참고
- **Object storage** - https://docs.gitlab.com/ee/administration/object_storage.html
- **GitLab IAM Permissions** - https://docs.gitlab.com/ee/administration/object_storage.html#iam-permissions
- **Omnibus GitLab reconfigure** - https://docs.gitlab.com/ee/administration/restart_gitlab.html#omnibus-gitlab-reconfigure
