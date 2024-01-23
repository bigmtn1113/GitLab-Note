# Standalone PostgreSQL database setting

<br>

Linux package를 이용해 GitLab 설치 후, 독립적인 PostgreSQL database 용도로 사용 가능.  
이 package는 charts의 services와의 호환성이 보장되는 services의 versions를 제공.

<br>

## Linux package 설치 구성

- `DB_USERNAME`: 기본 username은 `gitlab`.
- `DB_PASSSWORD`: Encoding 되지 않은 값.
- `DB_ENCODED_PASSWORD`: `DB_PASSWORD`의 encoding된 값.
- `AUTH_CIDR_ADDRESSMD5`: MD5 인증을 위한 CIDR을 구성하려면, cluster 또는 gateway의 가능한 가장 작은 subnets이어야 함.

> [!NOTE]
> - `DB_ENCODED_PASSWORD`는 다음 방법으로도 생성 가능:
>
>   - `echo -n 'DB_PASSSWORDDB_USERNAME' | md5sum - | cut -d' ' -f1`  
>	    `DB_USERNAME` 및 `DB_PASSWORD`를 실제 값으로 대체하여 생성.

1. `/etc/gitlab/gitlab.rb` 수정:

   ```ruby
   postgresql['listen_address'] = '0.0.0.0'
   postgresql['sql_user_password'] = "<DB_ENCODED_PASSWORD>"
   postgresql['md5_auth_cidr_addresses'] = ['<AUTH_CIDR_ADDRESSES>']    # ex. ['0.0.0.0/0']
   postgresql['trust_auth_cidr_addresses'] = ['127.0.0.1/24']           # ex. ['0.0.0.0/0']

   gitlab_rails['auto_migrate'] = false
   gitlab_rails['db_username'] = "gitlab"
   gitlab_rails['db_password'] = "<DB_PASSSWORD>"

   sidekiq['enable'] = false
   puma['enable'] = false
   registry['enable'] = false
   gitaly['enable'] = false
   gitlab_workhorse['enable'] = false
   nginx['enable'] = false
   prometheus_monitoring['enable'] = false
   redis['enable'] = false
   # gitlab_kas['enable'] = false
   ```

2. 변경 사항 재구성:

   ```
   gitlab-ctl reconfigure
   ```

3. 실행 중인 processes 확인:

   ```
   gitlab-ctl status
   ```

   ```
   # 출력 화면
   run: logrotate: (pid 4856) 1859s; run: log: (pid 31262) 77460s
   run: postgresql: (pid 30562) 77637s; run: log: (pid 30561) 77637s

   ```

<hr>

## 참고
- **Standalone PostgreSQL database setting** - https://docs.gitlab.com/charts/advanced/external-db/external-omnibus-psql.html
