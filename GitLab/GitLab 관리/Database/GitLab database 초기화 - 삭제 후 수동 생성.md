# GitLab database 초기화 - 삭제 후 수동 생성

<br>

GitLab postgresql data를 완전히 제거하고 다시 구성.

<br>

## 절차

1. GitLab의 모든 service 중지:

   ```
   gitlab-ctl stop
   ```

2. GitLab postgresql data가 있는 directory 삭제:

   ```
   rm -rf * /var/opt/gitlab/postgresql/data/
   ```

3. (선택사항) GitLab config file(`/etc/gitlab/gitlab.rb`)에서 postgresql 관련 설정 적용.

4. GitLab 재구성을 통해 자동으로 postgresql data 생성:

   ```
   gitlab-ctl reconfigure
   ```

   `/var/opt/gitlab/postgresql/data/`에 data가 다시 생긴 것 확인.

5. GitLab postgresql 시작:

   ```
   gitlab-ctl start postgresql
   ```

6. GitLab main database 삭제 후 재생성:

   ```
   gitlab-psql -d postgres
   ```
   ```sql
   DROP DATABASE gitlabhq_production;
   CREATE DATABASE gitlabhq_production OWNER gitlab;
   \q
   ```

7. GitLab database 구조 설정:

   ```
   gitlab:rake db:schema:load
   ```

8. 중지한 GitLab service 시작:

   ```
   gitlab-ctl restart
   ```

9. 정상 작동 여부를 빠르게 판단하는 개발/검증용 더미 데이터 생성:

   ```
   gitlab-rake db:seed_fu
   ```

10. (선택사항) Database 성능을 개선하고 UI의 불일치를 방지하기 위해 database 통계 생성:

    ```
    gitlab-rails dbconsole --database main
    ```
    ```sql
    SET STATEMENT_TIMEOUT=0 ; ANALYZE VERBOSE;
    ```
