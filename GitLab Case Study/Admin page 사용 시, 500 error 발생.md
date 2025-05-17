# Admin page 사용 시, 500 error 발생
Admin page에서 특정 menu를 선택하거나, admin 설정을 update할 시, 500 error가 발생할 때의 해결 방법 안내.

<br>

1. 암호화된 databse 값을 해독할 수 있는지 확인:
   ```shell
   sudo gitlab-rake gitlab:doctor:secrets
   ```

   e.g.
   ```
   ...
   I, [2020-06-23T10:51:08.354914 #803]  INFO -- : - ApplicationSetting failures: 1
   ...
   ```

2. PostgreSQL 접속:
   ```shell
   gitlab-psql -d gitlabhq_production
   ```

3. 문제되는 data 삭제:
   ```postgres
   DELETE FROM application_settings;
   ```

4. 암호화된 databse 값을 해독할 수 있는지 재확인:
   ```shell
   sudo gitlab-rake gitlab:doctor:secrets
   ```

   e.g.
   ```
   ...
   I, [2020-06-23T11:10:54.646765 #2195]  INFO -- : - ApplicationSetting failures: 0
   ...
   ```

5. Web UI에서 admin page 확인.

<hr>

## 참고
- **[Error 500 when updating admin settings after migration](https://gitlab.com/gitlab-org/gitlab/-/issues/220648)**
