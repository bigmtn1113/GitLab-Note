# Omnibus GitLab의 PostgreSQL data를 다른 directory에 저장

<br>

## 기본 구성

기본적으로 `postgresql['dir']` 속성에 의해 `/var/opt/gitlab/postgresql` 아래에 모든 것을 저장.

- Database socket은 `/var/opt/gitlab/postgresql/.s.PGSQL.5432`이며, 이는 `postgresql['unix_socket_directory']`에서 설정.
- `gitlab-psql` system user의 `HOME` directory는 `postgresql['home']`에서 설정.
- 실제 data는 `/var/opt/gitlab/postgresql/data`에 저장.

<br>

## Directory 변경

> [!WARNING]  
> 기존 database가 있는 경우, 먼저 data를 새 위치로 이동하는 작업 필수.  
> 이는 침입적인 작업이므로, 기존 설치에서는 가동 중지 시간 없이는 수행 불가.

1. GitLab DB directory 복사:

   ```
   cp -pR /var/opt/gitlab/postgresql/ <new location>
   ```

2. 기존 설치가 존재할 경우, GitLab 중지:

   ```
   gitlab-ctl stop
   ```

3. `/etc/gitlab/gitlab.rb` 수정:

   ```ruby
   postgresql['dir'] = "<new location>"
   ```

3. 변경 사항 적용:

   ```
   gitlab-ctl reconfigure
   ```

4. GitLab 시작:

   ```
   gitlab-ctl start
   ```

<hr>

## 참고
- **Omnibus GitLab의 PostgreSQL data를 다른 directory에 저장** - https://docs.gitlab.com/omnibus/settings/database.html#store-postgresql-data-in-a-different-directory
