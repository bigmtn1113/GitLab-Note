# Linux package CE to EE 변환

<br>

## 유의 사항
동일한 버전(ex: CE 12.1 to EE 12.1) 업그레이드 권장
  
<br>

## 절차
### 1. GitLab 백업 생성
```bash
sudo gitlab-backup create

# configuration 파일들 저장하기 위한 디렉터리 생성
mkdir -p /secret/gitlab/backups/

# configuration 파일들 백업
sudo gitlab-ctl backup-etc --backup-path /secret/gitlab/backups/
```
※ /secret/gitlab/backups/는 /etc/gitlab/과는 다른 안전한 경로로 지정
    
### 2. 현재 설치된 GitLab 버전 조회
#### Debian/Ubuntu
```bash
sudo apt-cache policy gitlab-ce | grep Installed
```

#### CentOS/RHEL
```bash
sudo rpm -q gitlab-ce
```

#### ※ GitLab 정보 조회
```ruby
gitlab-rake gitlab:env:info
```
※ 동일한 ee버전을 사용해야 하므로 버전 메모

### 3. gitlab-ee Apt 또는 Yum 저장소 추가
#### Debian/Ubuntu
```bash
curl --silent "https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh" | sudo bash
```

#### CentOS/RHEL
```bash
curl --silent "https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh" | sudo bash
```

### 4. gitlab-ee 패키지 설치
설치하면 GitLab 서버에서 gitlab-ce 패키지가 자동으로 제거

#### Debian/Ubuntu
```bash
sudo apt-get update

# 조회한 GitLab CE 버전과 동일한 EE 버전 설치
sudo apt-get install gitlab-ee=13.0.4-ee.0

# GitLab 재구성
sudo gitlab-ctl reconfigure
```

#### CentOS/RHEL
```bash
# 조회한 GitLab CE 버전과 동일한 EE 버전 설치
sudo yum install gitlab-ee-13.0.4-ee.0.el8.x86_64

# GitLab 재구성
sudo gitlab-ctl reconfigure
```

### 5. 라이선스를 추가하여 GitLab Enterprise Edition 활성화

### 6. GitLab이 예상대로 작동하는지 확인한 후 이전 Community Edition 저장소 제거
#### Debian/Ubuntu
```bash
sudo rm /etc/apt/sources.list.d/gitlab_gitlab-ce.list
```

#### CentOS/RHEL
```bash
sudo rm /etc/yum.repos.d/gitlab_gitlab-ce.repo
```

<br>

## ※ 업그레이드 후, 필수 구성 요소 복원(선택 사항)
```bash
# configuration 파일들 백업했을 경우 진행
sudo mv /etc/gitlab /etc/gitlab.$(date +%s)
cd /secret/gitlab/backups/

## C 옵션을 통해 / 경로에 압축 해제(압축 파일들이 /etc/gitlab 경로로 압축되어 있음)
sudo tar -xf gitlab_config_1666158098_2022_10_19.tar -C /

# GitLab 설정 적용
sudo gitlab-ctl reconfigure
sudo gitlab-ctl restart
sudo gitlab-rake gitlab:check SANITIZE=true

## /etc/gitlab/gitlab-secrets.json 파일이 복원된 경우 데이터베이스 값을 해독할 수 있는지 확인
sudo gitlab-rake gitlab:doctor:secrets
```

<hr>

## 참고
- **Linux package CE to EE** - https://docs.gitlab.com/ee/update/package/convert_to_ee.html
- **Backup GitLab** - https://docs.gitlab.com/ee/raketasks/backup_gitlab.html
- **Backup and restore Linux package configuration** - https://docs.gitlab.com/omnibus/settings/backups.html
