# 최근 활동이 없는 users block

<br>

관리자는 최근 활동이 없는 users block 가능.

<br>

## 절차
1. GitLab rails console에 접속:
   ```
   gitlab-rails console
   ```
2. 다음과 같이 Scripts 실행:
   ```ruby
   days_inactive = 90
   inactive_users = User.active.where("last_activity_on <= ?", days_inactive.days.ago)

   inactive_users.each do |user|
       puts "user '#{user.username}': #{user.last_activity_on}"
       user.block!
   end
   ```

   > 최근 활동 기준을 변경하려면 `days_inactive`값을 변경.

<hr>

## 참고
- **최근 활동이 없는 users block** - https://docs.gitlab.com/ee/administration/moderate_users.html#block-users-that-have-no-recent-activity
