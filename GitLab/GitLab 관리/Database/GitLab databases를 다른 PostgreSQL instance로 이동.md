# GitLab databases를 다른 PostgreSQL instance로 이동

<br>

때로는 하나의 PostgreSQL instance에서 다른 instance로 databases를 이동해야 하는 경우가 존재.  
예를 들어, AWS Aurora를 사용 중이고 Database Load Balancing 활성화를 준비 중인 경우, databases를 RDS for PostgreSQL로 이동하는 작업 필요.

<br>

## 절차

1. Source 및 destination PostgreSQL endpoint 정보 수집:

   ```
   SRC_PGHOST=<source postgresql host>
   SRC_PGUSER=<source postgresql user>

   DST_PGHOST=<destination postgresql host>
   DST_PGUSER=<destination postgresql user>
   ```

2. GitLab 중지:

   ```
   sudo gitlab-ctl stop
   ```

3. Source에서 databases dump:

   ```
   /opt/gitlab/embedded/bin/pg_dump -h $SRC_PGHOST -U $SRC_PGUSER -c -C -f gitlabhq_production.sql gitlabhq_production
   /opt/gitlab/embedded/bin/pg_dump -h $SRC_PGHOST -U $SRC_PGUSER -c -C -f praefect_production.sql praefect_production
   ```

4. Databases를 대상으로 복원(동일한 이름을 가진 기존 databases overwrite 진행):

   ```
   /opt/gitlab/embedded/bin/psql -h $DST_PGHOST -U $DST_PGUSER -f praefect_production.sql postgres
   /opt/gitlab/embedded/bin/psql -h $DST_PGHOST -U $DST_PGUSER -f gitlabhq_production.sql postgres
   ```

5. `/etc/gitlab/gitlab.rb`의 대상 PostgreSQL instance에 대한 적절한 연결 세부 정보로 GitLab 애플리케이션 서버를 구성:

   ```ruby
   gitlab_rails['db_host'] = '<destination postgresql host>'
   ```

6. 변경 사항 적용:

   ```
   sudo gitlab-ctl reconfigure
   ```

7. GitLab 시작:

   ```
   sudo gitlab-ctl start
   ```

<hr>

## 참고
- **GitLab databases를 다른 PostgreSQL instance로 이동** - https://docs.gitlab.com/ee/administration/postgresql/moving.html
