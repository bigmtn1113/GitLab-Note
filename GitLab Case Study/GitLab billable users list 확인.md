# GitLab billable users list 확인

<br>

GitLab license를 사용함으로써 비용 청구 대상으로 되어있는 users 현황 파악을 위해 GitLab Rails 기능을 사용.

<br>

## Billable users
Billable users는 subscription에서 구매한 subscription seats 수에 포함됨.

다음과 같은 경우, user는 billable user로 계산되지 않음:
- Deactivated 또는 blocked 상태.
- Pending approval 상태.
- 자체 관리형 Ultimate subscriptions 또는 GitLab.com subscription에 대한 Minimal Access role만 있는 상태.
- Ultimate subscription에서 Guest 또는 Minimal Access role만 있는 상태.
- Ultimate subscription에서 project 또는 group memberships가 없는 상태.
- GitLab에서 생성된 service 계정인 경우:
  - Ghost User.
  - 다음과 같은 bots:
    - Support Bot.
    - Projects의 bot users.
    - Groups의 bot users.
    - 기타 internal users.

Billable users 수는 Admin Area에 하루에 한 번 보고됨.

<br>

## Billable users 조회
1. GitLab Rails console 접속:

   ```
   gitlab-rails console
   ```

2. Ruby script 실행:

   ```ruby
   User.billable.find_each do |u|
       puts "#{u.username}, #{u.email}"
   end;
   ```

   예시 결과 화면:
   ```
   user-a, user-a@example.com
   user-b, user-b@example.com
   user-c, user-c@example.com
   user-d, user-d@example.com
   ```

   ※ Users 수만 조회할 경우 다음과 같이 실행:

   ```ruby
   User.billable.count
   ```

3. GitLab dashboard에서 users 수와 비교할 경우, GitLab web UI에서 다음과 같은 경로에서 확인:

   1. 좌측 sidebar 하단에 있는 **Admin Area** 선택.
   2. **Overview > Dashboard** 선택.
   3. **Instance overview > Users > Users Statistics** 선택.
   4. **Breakdown of Billable users > Total billable users** 확인.

      ![image](https://github.com/bigmtn1113/GitLab-Note/assets/46125158/12248fd5-d999-4a23-bd11-8a630a3a1a16)

<hr>

## 참고
- **Billable users** - https://docs.gitlab.com/ee/subscriptions/self_managed/#billable-users
