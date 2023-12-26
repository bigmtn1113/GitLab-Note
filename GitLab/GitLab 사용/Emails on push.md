# Emails on push

<br>

Emails on push를 활성화하면 project에 push되는 모든 변경 사항에 대한 email 알림 수신 가능.

<br>

## 절차
1. 왼쪽 sidebar에서 **Search or go to**을 선택하거나 project 찾기.
2. **Settings > Integrations** 선택.
3. **Emails on push** 선택.
4. **Recipients** section에서 공백 또는 개행으로 구분된 emails 목록 작성.
5. 다음 options 구성:
   - **Push events** - Push event가 수신되면 email이 trigger됨.
   - **Tag push events** - Tag가 생성되고 push될 때 email이 trigger됨.
   - **Send from committer** - Domain이 GitLab instance에서 사용되는 domain(ex: `user@gitlab.com`)과 일치하는 경우 committer의 email 주소에서 알림을 보냄.
   - **Disable code diffs** - 중요한 code diffs를 알림 본문에 미포함.

#### Settings
![emails_on_push_service_v13_11](https://github.com/bigmtn1113/GitLab-Note/assets/46125158/ae211ad3-fcd4-4559-bbef-cb455fb66980)

#### Notification
![emails_on_push_email](https://github.com/bigmtn1113/GitLab-Note/assets/46125158/d1cb28c0-a597-4584-a672-bf220f4e54cd)

<hr>

## 참고
- **Emails on push** - https://docs.gitlab.com/ee/user/project/integrations/emails_on_push.html
