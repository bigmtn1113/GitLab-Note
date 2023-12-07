# GitLab GEO

<br>

> [!WARNING]  
> Geo는 출시될 때마다 상당한 변화가 발생.  
> Upgrade가 지원되고 문서화되어 있지만 설치에 적합한 version의 문서를 사용하고 있는지 확인 필요.  
> 본 내용에선 `v15.11.11-ee`로 진행.

단일 GitLab instance에서 멀리 떨어져 있는 teams의 경우 대규모 repositories를 가져오는 데 오랜 시간이 걸릴 가능성 존재.  
Geo는 GitLab instances의 local 읽기 전용 sites를 제공.  
이를 통해 대규모 repositories를 복제하고 가져오는 데 걸리는 시간을 줄여, 개발 속도 향상 가능.

<br>

## 요구사항
- 독립적으로 작동하는 두 개 이상의 GitLab sites.
- Primary site에 GitLab Premium license 이상 적용.
- 동일한 GitLab version을 사용하는 sites.

### 방화벽 정책
Geo의 **primary**와 **secnodary** sites 사이에 열려 있어야 하는 기본 ports가 존재.  
장애 조치를 단순화하려면 양방향으로 ports를 open할 것.

Source site	| Source port	| Destination site | Destination port	| Protocol
:---: | :---: | :---: | :---: | :---:
Primary	| Any	| Secondary	| 80 | TCP (HTTP)
Primary	| Any	| Secondary	| 443	| TCP (HTTPS)
Secondary	| Any	| Primary	| 80 | TCP (HTTP)
Secondary	| Any	| Primary	| 443	| TCP (HTTPS)
Secondary | Any	| Primary	| 5432 | TCP

<br>

## PostgreSQL 복제
### Step 1. Primary site 구성
1. GitLab **primary** site에 SSH로 접속하고 root로 login:

   ```
   sudo -i
   ```
2. `/etc/gitlab/gitlab.rb`를 편집해서 site의 고유한 이름을 추가:

   ```ruby
   gitlab_rails['geo_node_name'] = '<site_name_here>'
   ```
3. 변경 사항이 적용되도록 **primary** site를 재구성:

   ```
   gitlab-ctl reconfigure
   ```
4. Site를 **primary** site로 정의:

   ```
   gitlab-ctl set-geo-primary-node
   ```
   이 명령은 `/etc/gitlab/gitlab.rb`의 `external_url`에 정의된 것을 사용.
5. `gitlab` database user의 비밀번호를 정의:

   원하는 비밀번호의 MD5 hash 생성:
   ```
   gitlab-ctl pg-password-md5 gitlab
   ```

   `/etc/gitlab/gitlab.rb` 편집:
   ```ruby
   postgresql['sql_user_password'] = '<md5_hash_of_your_password>'

   gitlab_rails['db_password'] = '<your_password_here>'
   ```
6. Database 복제 user의 비밀번호 정의.

   `postgresql['sql_replication_user']` 설정 아래 `/etc/gitlab/gitlab.rb`에 정의된 username(기본값은 `gitlab_replicator`)을 사용.  
   username을 다른 것으로 변경한 경우 아래 지침대로 진행.

   원하는 비밀번호의 MD5 hash 생성:
   ```
   gitlab-ctl pg-password-md5 gitlab_replicator
   ```

   `/etc/gitlab/gitlab.rb` 편집:
   ```ruby
   postgresql['sql_replication_password'] = '<md5_hash_of_your_password>'
   ```

   Omnibus GitLab에서 관리하지 않는 외부 database를 사용하는 경우 `gitlab_replicator` user를 생성하고 해당 user의 비밀번호를 수동으로 정의 해야 함:
   ```sql
   CREATE USER gitlab_replicator;
   ALTER USER gitlab_replicator WITH REPLICATION ENCRYPTED PASSWORD '<replication_password>';
   ```
7. `/etc/gitlab/gitlab.rb`를 편집해서 역할을 `geo_primary_role`로 설정:

   ```ruby
   roles(['geo_primary_role'])
   ```
8. Network interfaces를 수신하도록 PostgreSQL 구성:

   보안상의 이유로 PostgreSQL은 기본적으로 어떤 network interfaces에서도 수신 대기하지 않음.
   그러나 Geo를 사용하려면 **primary** site의 database에 연결할 수 있는 **secondary** site가 필요.
   이러한 이유로 각 site의 IP 주소가 필요.
   
   > 외부 PostgreSQL 인스턴스의 경우 추가 지침을 참조.
   
   `/etc/gitlab/gitlab.rb`를 편집해서 다음을 추가하여 IP 주소를 network 구성에 적합한 주소로 변경:
   ```ruby
   postgresql['listen_address'] = '<primary_site_ip>'       # ex) '0.0.0.0'
   postgresql['md5_auth_cidr_addresses'] = ['<primary_site_ip>/32', '<secondary_site_ip>/32']       # ex) ['0.0.0.0/0']
   ```
9. PostgreSQL이 다시 시작되고 private 주소를 수신할 때까지 자동 database migrations을 일시적으로 비활성화. `/etc/gitlab/gitlab.rb`를 편집해서 구성을 false로 변경:

   ```ruby
   gitlab_rails['auto_migrate'] = false
   ```
10. 선택사항: 다른 **secondary** site를 추가하려면 다음과 같이 설정:

    ```ruby
    postgresql['md5_auth_cidr_addresses'] = ['<primary_site_ip>/32', '<secondary_site_ip>/32', '<another_secondary_site_ip>/32']
    ```
11. File을 저장하고 database 수신 변경 사항 및 복제 slot 변경 사항이 적용되도록 GitLab을 재구성:

    ```
    gitlab-ctl reconfigure
    ```

    변경 사항을 적용하려면 PostgreSQL 재시작:
    ```
    gitlab-ctl restart postgresql
    ```
12. PostgreSQL이 재시작되고 private 주소에서 수신 대기하므로 migrations 재활성화:

    `/etc/gitlab/gitlab.rb`를 편집해서 구성을 `true`로 변경:
    ```ruby
    gitlab_rails['auto_migrate'] = true
    ```

    File을 저장하고 GitLab 재구성:

    ```
    gitlab-ctl reconfigure
    ```
13. 이제 PostgreSQL server가 원격 연결을 허용하도록 설정되었으므로 `netstat -plnt | grep 5432`를 실행하여 PostgreSQL이 port `5432`에서 **primary** site의 private 주소를 수신하고 있는지 확인.
14. GitLab이 재구성되면 인증서가 자동으로 생성됨. 이는 도청자로부터 PostgreSQL traffic을 보호하기 위해 자동으로 사용됨. "Man-In-The-Middle" 공격으로부터 보호하려면 **secondary** site에 인증서 복사본이 필요. 이 명령을 실행하여 **primary** site에 PostgreSQL `server.crt` file의 복사본 생성:

    ```
    cat ~gitlab-psql/data/server.crt
    ```

    **Secondary** site 설정할 때 필요하므로 출력을 clipboard나 local file에 복사.

<br>

### Step 2. Secondary server 구성
1. GitLab **secondary** site에 SSH로 접속하고 root로 login:

   ```
   sudo -i
   ```
2. Application server 및 Sidekiq 중지:

   ```
   gitlab-ctl stop puma
   gitlab-ctl stop sidekiq
   ```

   > 이 단계는 중요하므로 site가 완전히 구성되기 전에 아무것도 실행하지 말 것.
3. **Primary** site의 PostgreSQL server에 대한 TCP 연결 확인:

   ```
   gitlab-rake gitlab:tcp_check[<primary_site_ip>,5432]
   ```
4. **Primary** site 설정의 마지막 단계에서 얻은 내용를 사용하여 **secondary** site에 `server.crt` file을 생성:

   ```
   editor server.crt
   ```
5. **Secondary** site에서 PostgreSQL TLS 확인 설정:

   `server.crt` file 설치:
   ```
   install \
      -D \
      -o gitlab-psql \
      -g gitlab-psql \
      -m 0400 \
      -T server.crt ~gitlab-psql/.postgresql/root.crt
   ```

   이제 PostgreSQL은 TLS 연결을 확인할 때 정확한 인증서만 인식.  
   인증서는 **primary** site에만 있는 private key에 access할 수 있는 사람에 의해서만 복제될 수 있음.
6. `gitlab-psql` user가 **primary** site의 database(기본 Omnibus database 이름은 `gitlabhq_production`)에 연결할 수 있는지 test:

   ```
   sudo \
      -u gitlab-psql /opt/gitlab/embedded/bin/psql \
      --list \
      -U gitlab_replicator \
      -d "dbname=gitlabhq_production sslmode=verify-ca" \
      -W \
      -h <primary_site_ip>
   ```

   Message가 표시되면 첫 번째 단계에서 `gitlab_replicator` user에 대해 설정한 일반 text 비밀번호를 입력.  
   모두 올바르게 작동했다면 **primary** site의 databases 목록이 표시되어야 함.

   여기서 연결에 실패하면 TLS 구성이 올바르지 않음을 나타냄.  
   **Primary** site의 `~gitlab-psql/data/server.crt` 내용이 **secondary** site의 `~gitlab-psql/.postgresql/root.crt` 내용과 일치하는지 확인.
7. `/etc/gitlab/gitlab.rb`를 편집해서 역할을 `geo_secondary_role`로 설정:

   ```ruby
   roles(['geo_secondary_role'])
   ```
8. PostgreSQL 구성:

   이 단계는 **primary** instance를 구성한 방법과 유사.
   
   `/etc/gitlab/gitlab.rb`를 편집해서 다음을 추가하여 IP 주소를 network 구성에 적합한 주소로 변경:
   ```ruby
   postgresql['listen_address'] = '<secondary_site_ip>'       # ex) '0.0.0.0'
   postgresql['md5_auth_cidr_addresses'] = ['<secondary_site_ip>/32']       # ex) ['0.0.0.0/0']
   postgresql['sql_replication_password'] = '<md5_hash_of_your_password>'
   postgresql['sql_user_password'] = '<md5_hash_of_your_password>'

   gitlab_rails['db_password'] = '<your_password_here>'
   ```
9. 변경 사항이 적용되도록 GitLab을 재구성:

   ```
   gitlab-ctl reconfigure
   ```
10. IP 변경 사항을 적용하려면 PostgreSQL을 재시작:

    ```
    gitlab-ctl restart postgresql
    ```

<br>

### Step 3. 복제 process 시작
다음은 **secondary** site의 database를 **primary** site의 database에 연결하는 script.  
이 script는 database를 복제하고 streaming 복제에 필요한 files를 생성.

사용되는 directories는 Omnibus에 설정된 기본값.  
기본값을 변경한 경우, 그에 따라 script를 구성하여 모든 directories와 경로 변경 필요.

> [!WARNING]
> `pg_basebackup`을 실행하기 전에 PostgreSQL의 모든 data를 제거하므로 **secondary** site에서 이를 실행할 것.

1. GitLab **secondary** site에 SSH로 접속하고 root로 login:

   ```
   sudo -i
   ```
2. **Secondary** site에서 복제 slot 이름으로 사용할 database 친화적인 이름 선택. 예를 들어 domain이 `secondary.geo.example.com`인 경우 `secondary_example`을 slot 이름으로 사용.
3. Backup/restore을 시작하고 복제 시작:

   > 각 Geo **secondary**에는 고유한 복제 slot 이름 필요.  
   > 두 **secondary** databases 간에 동일한 slot 이름을 사용하면 PostgreSQL 복제가 중단됨.  
   > 복제 slot 이름에는 소문자, 숫자, 밑줄 문자(_)만 포함되어야 함.
   
   ```
   gitlab-ctl replicate-geo-database \
      --slot-name=<secondary_site_name> \
      --host=<primary_site_ip> \
      --sslmode=verify-ca
   ```

   Message가 표시되면 첫 번째 단계에서 `gitlab_replicator` user에 대해 설정한 일반 text 비밀번호를 입력.

<br>

## Database에서 authorized SSH keys를 빠르게 조회하도록 구성.
OpenSSH는 선형 검색을 통해 user에게 권한을 부여하는 key를 검색하므로 users 수가 증가함에 따라 일반 SSH 작업이 느려짐.  
User에게 GitLab access 권한이 없는 경우와 같은 최악의 경우 OpenSSH는 전체 file을 scan하여 key를 검색.  
여기에는 상당한 시간과 disk I/O가 소요될 수 있으며 이로 인해 users가 repository에 push하거나 pull하려는 시도가 지연됨.  
게다가, users가 keys를 자주 추가하거나 제거하면 운영 체제가 `authorized_keys` file을 cache하지 못해 disk에 반복적으로 access하게 될 가능성 존재.

GitLab Shell은 GitLab database에서 빠른 색인 조회를 통해 SSH users에게 권한을 부여하는 방법을 제공하여 이 문제를 해결.  
GitLab Shell은 SSH key의 fingerprint를 사용하여 user가 GitLab에 access할 수 있는 권한이 있는지 확인.

> [!IMPORTANT]  
> **Primary** site와 **secondary** site 모두 진행.

1. `sshd_config` file에 다음을 추가. 이 file은 일반적으로 `/etc/ssh/sshd_config`에 있지만 Omnibus Docker를 사용하는 경우에는 `/assets/sshd_config`에 존재:

   ```
   Match User git    # Apply the AuthorizedKeysCommands to the git user only
   AuthorizedKeysCommand /opt/gitlab/embedded/service/gitlab-shell/bin/gitlab-shell-authorized-keys-check git %u %k
   AuthorizedKeysCommandUser git
   Match all    # End match, settings apply to all users again
   ```
2. OpenSSH reload:

   ```
   # Debian or Ubuntu installations
   sudo service ssh reload

   # CentOS installations
   sudo service sshd reload
   ```
3. `authorized_keys` file에서 user's key를 주석 처리하여 SSH가 작동하는지 확인하고 local machine에서 repository를 pull하거나 다음을 실행:

   ```
   ssh -T git@<GITLAB_DOMAIN>
   ```

   성공적인 pull 또는 환영 message는 file에 존재하지 않는 key를 GitLab이 database에서 찾을 수 있다는 의미.
4. `authorized_keys` file 쓰기 권한 비활성화:

   > **Primary** site에서만 진행.  
   > GitLab 구성이 완료되어 UI 접속이 된 후에 진행.  
   > SSH가 완벽하게 작동하는 것으로 확인될 때까지 쓰기 비활성화 금지.  
   > 그렇지 않으면 file이 빨리 out-of-date됨.

   1. 상당 표시줄에서 **Main menu > Admin** 선택.
   2. 왼쪽 sidebar에서 **Settings > Network** 선택.
   3. **Performance optimization** 확장.
   4. **Use authorized_keys file to authenticate SSH keys** checkbox 선택 취소.
   5. **Save changes** 선택.

   다시 한 번 UI에서 user의 SSH key를 제거하고 새 key를 추가한 후 repository pull을 시도하여 SSH가 작동하는지 확인.  
   그런 다음 최상의 성능을 위해 `authorized_keys` file을 백업하고 삭제 가능.  
   현재 users의 kyes는 이미 database에 있으므로 migration하거나 users의 keys 재추가 불필요.

<br>

## **Secondary** site 구성
이는 보조 Geo 사이트 설정의 마지막 단계

> [!IMPORTANT]
> 보조 사이트 에 대해서는 사용자 정의 인증을 설정 하지 마십시오 . 이는 기본 사이트 에서 처리됩니다 . 보조 사이트는 읽기 전용 복제본 이므로 관리 영역 에 액세스해야 하는 모든 변경은 기본 사이트 에서 수행되어야 합니다 .

### Step 1. GitLab secret 값을 수동으로 복제

<br>

### Step 2. Primary site의 SSH host keys를 수동으로 복제

<br>

### Step 3. Secondary site 추가

<br>

### Step 4. HTTP/HTTPS 및 SSH를 통한 Git access 활성화

<br>

### Step 5. Secondary site가 제대로 작동하는지 확인

<hr>

## 참고
- **GitLab GEO** - https://archives.docs.gitlab.com/15.11/ee/administration/geo/
- **Database 복제** - https://archives.docs.gitlab.com/15.11/ee/administration/geo/setup/database.html
- **Database에서 authorized SSH keys를 빠르게 조회** - https://archives.docs.gitlab.com/15.11/ee/administration/operations/fast_ssh_key_lookup.html
- **GEO 구성** - https://archives.docs.gitlab.com/15.11/ee/administration/geo/replication/configuration.html
