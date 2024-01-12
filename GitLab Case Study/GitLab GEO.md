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

## Glossary
Geo의 모든 측면을 설명하기 위해 정의된 용어.  
명확하게 정의된 용어 집합을 사용하면 효율적인 의사소통 및 혼란 방지 가능.

용어 | 정의	| 범위 
:---: | :---: | :---:
Node | 특정 역할 또는 전체(예: Rails application node)로 GitLab을 실행하는 개별 server. | GitLab
Site | 단일 GitLab application을 실행하는 하나 또는 nodes 모음. 단일 node 또는 다중 node일 수 있음. | GitLab
Single-node site | 정확히 하나의 node를 사용하는 GitLab의 특정 구성. | GitLab
Multi-node site | 둘 이상의 nodes를 사용하는 GitLab의 특정 구성. | GitLab
Primary site | 하나 이상의 secondary site에서 데이터가 복제되는 GitLab site. Primary site는 하나만 존재. | Geo-specific
Secondary site | Primary site의 data를 복제하도록 구성된 GitLab site. 하나 이상의 secondary sites가 있을 수 있음. | Geo-specific
Geo deployment | 정확히 하나의 primary site가 하나 이상의 secondary sites에 의해 복제되는 두 개 이상의 GitLab site 모음. | Geo-specific

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
   
   > 외부 PostgreSQL instance의 경우 추가 지침을 참조.
   
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

   > 위의 명령어를 수행할 수 없을 경우 다음과 같이 실행:  
   > ```
   > gitlab-psql \
   >    --list \
   >    -U gitlab_replicator \
   >    -d "dbname=gitlabhq_production sslmode=verify-ca" \
   >    -W \
   >    -h <primary_site_ip>
   > ```

   Message가 표시되면 첫 번째 단계에서 `gitlab_replicator` user에 대해 설정한 일반 text 비밀번호를 입력.  
   모두 올바르게 작동했다면 **primary** site의 databases 목록이 표시되어야 함.

   여기서 연결에 실패하면 TLS 구성이 올바르지 않음을 나타냄.  
   **Primary** site의 `~gitlab-psql/data/server.crt` 내용이 **secondary** site의 `~gitlab-psql/.postgresql/root.crt` 내용과 일치하는지 확인.
8. `/etc/gitlab/gitlab.rb`를 편집해서 역할을 `geo_secondary_role`로 설정:

   ```ruby
   roles(['geo_secondary_role'])
   ```
9. PostgreSQL 구성:

   이 단계는 **primary** instance를 구성한 방법과 유사.
   
   `/etc/gitlab/gitlab.rb`를 편집해서 다음을 추가하여 IP 주소를 network 구성에 적합한 주소로 변경:
   ```ruby
   postgresql['listen_address'] = '<secondary_site_ip>'       # ex) '0.0.0.0'
   postgresql['md5_auth_cidr_addresses'] = ['<secondary_site_ip>/32']       # ex) ['0.0.0.0/0']
   postgresql['sql_replication_password'] = '<md5_hash_of_your_password>'
   postgresql['sql_user_password'] = '<md5_hash_of_your_password>'

   gitlab_rails['db_password'] = '<your_password_here>'
   ```
10. 변경 사항이 적용되도록 GitLab을 재구성:

    ```
    gitlab-ctl reconfigure
    ```
11. IP 변경 사항을 적용하려면 PostgreSQL을 재시작:

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
이는 **secondary** Geo site 설정의 마지막 단계.

> [!IMPORTANT]  
> **secondary** sites에 대해서는 사용자 정의 인증을 설정하지 말 것. 이는 **primary** sote에서 처리됨.  
> **Secondary** site는 읽기 전용 복제본이므로 **Admin Area**에 access해야 하는 모든 변경은 **primary** site에서 수행되어야 함.

### Step 1. GitLab secret 값을 수동으로 복제
GitLab은 site의 모든 nodes에서 동일해야 하는 여러 secret 값을 `/etc/gitlab/gitlab-secrets.json` file에 저장.  
Sites 간에 자동으로 복제할 수 있는 수단이 있을 때까지 **secondary** site의 모든 nodes에 수동으로 복제 필요.

1. **Primary** site의 **Rails node**에 SSH로 접속하고 아래 명령을 실행:

   ```
   sudo cat /etc/gitlab/gitlab-secrets.json
   ```

   복제해야 하는 secrets가 JSON 형식으로 표시됨.
2. **Secondary** site의 **각 node**에 SSH로 접속하고 root로 login:

   ```
   sudo -i
   ```
3. 기존 secrets backup:

   ```
   mv /etc/gitlab/gitlab-secrets.json /etc/gitlab/gitlab-secrets.json.`date +%F`
   ```
4. **primary** site의 **Rails node**에서 **secondary** site의 **각 node**로 `/etc/gitlab/gitlab-secrets.json`를 복사하거나, nodes 간에 file 내용을 복사하여 붙여넣을 것:

   ```
   sudo editor /etc/gitlab/gitlab-secrets.json
   ```
5. File 권한이 올바른지 확인:

   ```
   chown root:root /etc/gitlab/gitlab-secrets.json
   chmod 0600 /etc/gitlab/gitlab-secrets.json
   ```
6. 변경 사항을 적용하려면 **secondary** site에서 **각 Rails, Sidekiq 및 Gitaly nodes**를 재구성:

   ```
   gitlab-ctl reconfigure
   gitlab-ctl restart
   ```

<br>

### Step 2. Primary site의 SSH host keys를 수동으로 복제
GitLab은 system에 설치된 SSH daemon과 통합되어 모든 access 요청이 처리되는 user(일반적으로 `git`)를 지정.

재해 복구 상황에서 GitLab system 관리자는 **secondary** site를 **primary** site로 승격.  
**Primary** domain의 DNS records도 새 **primary** site(이전의 **secondary** site)를 가리키도록 update 필요.  
이렇게 하면 Git 원격 및 API URLs를 update 불필요.

이로 인해 SSH host key 불일치로 인해 새로 승격된 **primary** site에 대한 모든 SSH 요청이 실패하게 되는데, 이를 방지하려면 **primary** SSH host keys를 **secondary** site에 수동으로 복제 필요.

1. **Secondary** site의 **각 node**에 SSH로 접속하고 root로 login:

   ```
   sudo -i
   ```
2. 기존 SSH host keys backup:

   ```
   find /etc/ssh -iname 'ssh_host_*' -exec cp {} {}.backup.`date +%F` \;
   ```
3. **Primary** site에서 OpenSSH host keys 복사:

   **root** user를 사용하여 SSH traffic을 제공하는 **primary** site의 **nodes**(일반적으로 main GitLab Rails application nodes) 중 하나에 access할 수 있는 경우:
   ```
   scp root@<primary_node_fqdn>:/etc/ssh/ssh_host_*_key* /etc/ssh
   ```

   `scp`를 사용할 수 없는 경우:
   ```
   # Primary site의 node에서 실행
   sudo tar --transform 's/.*\///g' -zcvf ~/geo-host-key.tar.gz /etc/ssh/ssh_host_*_key*

   # 생성된 geo-host-key.tar.gz을 secondary site의 각 node로 옮긴 후 진행:
   tar zxvf ~/geo-host-key.tar.gz -C /etc/ssh
   ```
4. **Secondary** site의 **각 node**에서 file 권한이 올바른지 확인:

   ```
   chown root:root /etc/ssh/ssh_host_*_key*
   chmod 0600 /etc/ssh/ssh_host_*_key
   ```
5. Key fingerprint 일치를 확인하려면 각 site의 **primary** node와 **secondary** node 모두에서 다음 명령을 실행:

   ```
   for file in /etc/ssh/ssh_host_*_key; do ssh-keygen -lf $file; done
   ```

   다음과 유사한 출력을 얻어야 하며 두 nodes에서 모두 동일해야 함:
   ```
   1024 SHA256:FEZX2jQa2bcsd/fn/uxBzxhKdx4Imc4raXrHwsbtP0M root@serverhostname (DSA)
   256 SHA256:uw98R35Uf+fYEQ/UnJD9Br4NXUFPv7JAUln5uHlgSeY root@serverhostname (ECDSA)
   256 SHA256:sqOUWcraZQKd89y/QQv/iynPTOGQxcOTIXU/LsoPmnM root@serverhostname (ED25519)
   2048 SHA256:qwa+rgir2Oy86QI+PZi/QVR+MSmrdrpsuH7YyKknC+s root@serverhostname (RSA)
   ```
6. 기존 private keys에 대한 올바른 public keys가 있는지 확인:

   ```
   for file in /etc/ssh/ssh_host_*_key; do ssh-keygen -lf $file; done
   for file in /etc/ssh/ssh_host_*_key.pub; do ssh-keygen -lf $file; done
   ```

   > Private keys 및 public keys 명령의 출력은 동일한 fingerprint를 생성해야 함.
7. **Secondary** site의 **각 node**에서 `sshd` 재시작:
   ```
   # Debian or Ubuntu installations
   sudo service ssh reload

   # CentOS installations
   sudo service sshd reload
   ```
8. SSH가 여전히 작동하는지 확인.

   새 terminal에서 GitLab **secondary** server에 SSH를 통해 연결.  
   연결할 수 없는 경우 이전 단계에 따라 권한이 올바른지 확인.

<br>

### Step 3. Secondary site 추가
1. **Secondary** site의 **각 Rails 및 Sidekiq node**에 SSH로 접속하고 root로 login:

   ```
   sudo -i
   ```
2. `/etc/gitlab/gitlab.rb`을 편집해서 site의 **고유한** 이름을 추가. 다음 단계에서 이 정보가 필요:

   ```
   gitlab_rails['geo_node_name'] = '<site_name_here>'
   ```
3. 변경 사항을 적용하려면 **secondary** site에서 **각 Rails 및 Sidekiq node**를 재구성:

   ```
   gitlab-ctl reconfigure
   ```
4. **Primary** node GitLab instance로 이동:

   1. 상단 표시줄에서 **Main menu > Admin** 선택.
   2. 왼쪽 sidebar에서 **Geo > Sites** 선택.
   3. **Add site** 선택.
      ![adding_a_secondary_v15_8](https://github.com/bigmtn1113/GitLab-Note/assets/46125158/3021581b-e3a1-4f7e-929e-eeb499c5852a)
   4. **Name**에 `/etc/gitlab/gitlab.rb`의 `gitlab_rails['geo_node_name']` 값을 입력. 이러한 값은 항상 정확하게 일치 필요.
   5. **External URL**에 `/etc/gitlab/gitlab.rb`의 `external_url` 값을 입력. 이러한 값은 항상 일치해야 하지만, `/`로 끝나든 그렇지 않든 상관없음.
   6. 선택 사항. **Internal URL (optional)** 에 primary site의 internal URL을 입력.
   7. 선택 사항. **Secondary** site에서 복제해야 하는 groups 또는 storage shards 선택. 모두 복제하려면 비워 둘 것.
   8. **Save changes**를 선택하여 **secondary** site 추가.
5. **Secondary site의 각 Rails 및 Sidekiq node**에 SSH를 통해 연결하고 services 재시작:

   ```
   gitlab-ctl restart
   ```

   다음을 실행하여 Geo 설정에 일반적인 문제가 있는지 확인:
   ```
   gitlab-rake gitlab:geo:check
   ```
6. **Primary** site의 **Rails 또는 Sidekiq server**에 SSH로 접속하고 root로 로그인하여 **secondary** site에 연결할 수 있는지 또는 Geo 설정에 일반적인 문제가 있는지 확인:

   ```
   gitlab-rake gitlab:geo:check
   ```

**Secondary** site가 Geo 관리 page에 추가되고 재시작되면 site는 **backfill**이라는 process를 통해 **primary** site에서 누락된 data를 자동으로 복제하기 시작. 
그 사이에 **primary** site는 각 **secondary** site에 변경 사항을 알리기 시작하므로 **secondary** site는 해당 알림에 대해 즉시 조치 가능.

**Secondary** site가 실행 중이고 access 가능한지 확인.  
**Primary** site에 사용된 것과 동일한 자격 증명을 사용하여 **secondary** site에 login 가능.

<br>

### Step 4. HTTP/HTTPS 및 SSH를 통한 Git access 활성화
Geo는 HTTP/HTTPS를 통해 저장소를 동기화하므로 해당 clone 방법 활성화 필요.  
이는 기본적으로 활성화되어 있지만 기존 site를 Geo로 변환하는 경우 다음과 같이 확인 필요:

**Primary** site에서 진행:
1. 상단 표시줄에서 **Main menu > Admin** 선택.
2. 왼쪽 sidebar에서 **Settings > General** 선택.
3. **Visibility and access controls** 확장.
4. SSH를 통해 Git을 사용하는 경우:
   1. "Enabled Git access protocols"가 "Both SSH and HTTP(S)"로 설정되어 있는지 확인.
   2. Primary site와 secondary site 모두의 database에서 authorized SSH keys를 빠르게 조회하도록 설정.
5. SSH를 통해 Git을 사용하지 않는 경우, "Enabled Git access protocols"를 "Only HTTP(S)"로 설정.

<br>

### Step 5. Secondary site가 제대로 작동하는지 확인
**Primary** site에서 사용한 것과 동일한 자격 증명을 사용하여 **secondary** site에 login 가능. Login한 후 진행:

1. 상단 표시줄에서 **Main menu > Admin** 선택.
2. 왼쪽 sidebar에서 **Geo > Sites** 선택.
3. **Secondary** Geo site로 올바르게 식별되고 Geo가 활성화되어 있는지 확인.

초기 복제에는 다소 시간이 걸릴 수 있고, site 상태 또는 'backfill'이 아직 진행 중일 가능성 존재.  
Browser에 있는 **primary** site의 **Geo Sites** dashboard에서 각 Geo site의 동기화 process monitoring 가능.  
![geo_dashboard_v14_0](https://github.com/bigmtn1113/GitLab-Note/assets/46125158/49f6c468-3aa7-43b4-94c6-a102747c913f)

Dashboard에서 명백하게 드러날 수 있는 가장 확실한 두 가지 문제:
1. Database 복제가 제대로 작동하지 않음.
2. Instance 간 알림이 작동하지 않음. 이 경우 다음 중 하나일 가능성 존재:
   - 사용자 정의 인증서 또는 사용자 정의 CA를 사용.
   - Instance에 방화벽이 설정되어 있는 경우.

**Secondary** site를 비활성화하면 동기화 process가 중지됨.

현재 동기화되는 내용:
- Git repositories.
- Wikis.
- LFS 객체.
- Issues, 병합 요청, snippets, 댓글 attachments.
- Users, groups 및 project avatars.

<hr>

## 참고
- **GitLab GEO** - https://archives.docs.gitlab.com/15.11/ee/administration/geo/
- **Geo Glossary** - https://docs.gitlab.com/ee/administration/geo/glossary.html
- **Database 복제** - https://archives.docs.gitlab.com/15.11/ee/administration/geo/setup/database.html
- **Database에서 authorized SSH keys를 빠르게 조회** - https://archives.docs.gitlab.com/15.11/ee/administration/operations/fast_ssh_key_lookup.html
- **GEO 구성** - https://archives.docs.gitlab.com/15.11/ee/administration/geo/replication/configuration.html
