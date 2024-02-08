# Geo secondary site 복제 재설정

<br>

손상된 상태의 **secondary** site가 있고 복제 상태를 재설정하고 처음부터 다시 시작하려는 경우, 도움이 될 수 있는 몇 가지 단계 존재.

<br>

## 절차
1. Sidekiq 및 Geo LogCursor 중지.

   Sidekiq을 정상적으로 중지하는 것이 가능하지만, 새 jobs 가져오기를 중지하고 현재 jobs이 처리를 마칠 때까지 기다리게 할 수 있음.

   첫 번째 단계에서는 **SIGTSTP** 종료 신호를 보내고 모든 jobs가 완료되면 **SIGTERM**을 보내야 함. 그렇지 않으면 그냥 `gitlab-ctl stop` 명령 사용.

   ```
   gitlab-ctl status sidekiq
   # run: sidekiq: (pid 10180) <- this is the PID you will use
   kill -TSTP 10180 # change to the correct PID

   gitlab-ctl stop sidekiq
   gitlab-ctl stop geo-logcursor
   ```

   Sidekiq logs를 보고 Sidekiq jobs 처리가 언제 완료되었는지 확인 가능:  
   ```
   gitlab-ctl tail sidekiq
   ```

2. Repository storage filders의 이름을 바꾸고 새 folders 생성. Orphaned directories 및 files가 걱정되지 않으면 이 단계 생략 가능.

   ```
   mv /var/opt/gitlab/git-data/repositories /var/opt/gitlab/git-data/repositories.old
   mkdir -p /var/opt/gitlab/git-data/repositories
   chown git:git /var/opt/gitlab/git-data/repositories
   ```

   > Disk 공간을 절약하기 위해 나중에 더 이상 필요하지 않다는 것을 확인하는 즉시 `/var/opt/gitlab/git-data/repositories.old` 제거 가능.

3. 선택 사항. 다른 data folders의 이름을 바꾸고 새 folders 생성.

   > **Primary** site에서 제거된 files가 **secondary** site에 여전히 남아 있을 수 있지만, 이러한 제거는 반영되지 않음.  
   > 이 단계를 건너뛰면, 이러한 files는 Geo **secondary** site에서 제거되지 않음.

   Upload된 content(ex. file attachments, avatars 또는 LFS objectts)는 다음 경로 중 하나의 하위 folder에 저장됨:  
   - `/var/opt/gitlab/gitlab-rails/shared`
   - `/var/opt/gitlab/gitlab-rails/uploads`

   모든 이름을 바꾸려면 다음을 수행:  
   ```
   gitlab-ctl stop

   mv /var/opt/gitlab/gitlab-rails/shared /var/opt/gitlab/gitlab-rails/shared.old
   mkdir -p /var/opt/gitlab/gitlab-rails/shared

   mv /var/opt/gitlab/gitlab-rails/uploads /var/opt/gitlab/gitlab-rails/uploads.old
   mkdir -p /var/opt/gitlab/gitlab-rails/uploads

   gitlab-ctl start postgresql
   gitlab-ctl start geo-postgresql
   ```

   Folders를 다시 생성하고 권한과 소유권이 올바른지 확인하도록 재구성:  
   ```
   gitlab-ctl reconfigure
   ```

4. Tracking Database 재설정.

   > 3단계를 건너뛴 경우, `geo-postgresql` 및 `postgresql` services가 모두 실행 중인지 확인.

   ```
   gitlab-rake db:drop:geo DISABLE_DATABASE_ENVIRONMENT_CHECK=1   # on a secondary app node
   gitlab-ctl reconfigure     # on the tracking database node
   gitlab-rake db:migrate:geo # on a secondary app node
   ```

5. 이전에 중지된 services 재시작.

   ```
   gitlab-ctl start
   ```

<hr>

## 참고
- **Geo secondary site replication 재설정** - https://docs.gitlab.com/ee/administration/geo/replication/troubleshooting.html#resetting-geo-secondary-site-replication
