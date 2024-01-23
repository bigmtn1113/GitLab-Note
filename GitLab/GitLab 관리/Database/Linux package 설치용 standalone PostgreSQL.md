# Linux package 설치용 standalone PostgreSQL

<br>

Database service를 GitLab application servers와 별도로 hosting하려면 Linux package와 함께 package된 PostgreSQL binaries를 사용.

<br>

## 설정

1. PostgreSQL server에 SSH로 접속.

2. GitLab Linux package download 및 install.

3. PostgreSQL에 대한 password hash 생성:

   > `gitlab`(권장)의 기본 username을 사용하고 있다고 가정. 이 명령은 비밀번호와 확인을 요청.  
   > 다음 단계에서 이 명령으로 출력되는 값을 `POSTGRESQL_PASSWORD_HASH` 값으로 사용.

   ```
   sudo gitlab-ctl pg-password-md5 gitlab
   ```

4. `/etc/gitlab/gitlab.rb` 수정:

   > `APPLICATION_SERVER_IP_BLOCKS`: database에 연결하는 GitLab application servers의 IP subnets 또는 IP 주소를 공백으로 구분한 목록.
   
   ```ruby
   roles(['postgres_role'])
   prometheus['enable'] = false
   alertmanager['enable'] = false
   pgbouncer_exporter['enable'] = false
   redis_exporter['enable'] = false
   gitlab_exporter['enable'] = false
   # prometheus_monitoring['enable'] = false    # Monitoring 하지 않을 경우

   postgresql['listen_address'] = '0.0.0.0'
   postgresql['port'] = 5432
   postgresql['sql_user_password'] = '<POSTGRESQL_PASSWORD_HASH>'
   postgresql['trust_auth_cidr_addresses'] = %w(<APPLICATION_SERVER_IP_BLOCKS>)            # ex. %w(0.0.0.0/0)

   gitlab_rails['auto_migrate'] = false
   ```

2. 변경 사항 재구성:

   ```
   gitlab-ctl reconfigure
   ```

3. 실행 중인 processes 확인:

   ```
   gitlab-ctl status
   ```

4. PostgreSQL node의 IP 주소 또는 hostname, port 및 일반 text 비밀번호를 기록해 둘 것. 이는 나중에 GitLab application servers를 구성할 때 필요.

<hr>

## 참고
- **Linux package 설치용 standalone PostgreSQL** - https://docs.gitlab.com/ee/administration/postgresql/standalone.html
