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
   
   ※ 외부 PostgreSQL 인스턴스의 경우 추가 지침을 참조.
   
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

   ※ 이 단계는 중요하므로 site가 완전히 구성되기 전에 아무것도 실행하지 말 것.
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

<hr>

## 참고
- **GitLab GEO** - https://archives.docs.gitlab.com/15.11/ee/administration/geo/
- **Database 복제** - https://archives.docs.gitlab.com/15.11/ee/administration/geo/setup/database.html
