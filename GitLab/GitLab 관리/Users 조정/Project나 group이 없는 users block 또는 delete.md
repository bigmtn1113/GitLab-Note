# Project나 group이 없는 users block 또는 delete

<br>

관리자는 Project나 group이 없는 users block 또는 delete 가능.

<br>

## 절차
1. GitLab rails console에 접속:

   ```
   gitlab-rails console
   ```
2. 다음과 같이 Scripts 실행:

   - Block users:
     ```ruby
     users = User.where('id NOT IN (select distinct(user_id) from project_authorizations)')

     users.count
     
     users.each { |user|  user.blocked? ? nil  : user.block! }
     ```

     > 위의 작업으로 인해 block된 users activation:  
     > ```ruby
     > users = User.where('id NOT IN (select distinct(user_id) from project_authorizations)')
     >
     > users.count
     >
     > users.each { |user|  user.blocked? ? user.activate! : nil }
     > ```

   - Delete users:
     ```ruby
     users = User.where('id NOT IN (select distinct(user_id) from project_authorizations)')

     users.count

     current_user = User.find_by(username: '<your username>')

     users.each do |user|
       DeleteUserWorker.perform_async(current_user.id, user.id)
     end
     ```

<hr>

## 참고
- **Project나 group이 없는 users block 또는 delete** - https://docs.gitlab.com/ee/administration/moderate_users.html#block-or-delete-users-that-have-no-projects-or-groups
