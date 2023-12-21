# 휴면 users 자동 deactivation

<br>

GitLab 관리자는 users를 approving, blocking, banning 또는 deactivating하여 user access 조정 가능.

관리자는 다음 중 하나에 해당하는 users에 대해 자동 deactivation 적용 가능:
- 생성된 지 일주일이 넘었고 login한 적이 없을 경우.
- 지정된 기간(기본값, 최소값은 90일)동안 활동이 없을 경우.

<br>

## 절차
1. 왼쪽 sidebar 하단에서 **Admin Area** 선택.
2. **Settings > General** 선택.
3. **Account and Limit** section 확장.
4. **Dormant users** 아래에서 **Deactivate dormant users after a period of inactivity** 선택.
5. **Days of inactivity before deactivation** 아래에 deactivation되기 전까지 남은 일수 입력. 최소값은 90일.
6. **Save changes** 선택.

이 기능이 활성화되면 GitLab은 하루에 한 번 작업을 실행하여 휴면 users를 deactivation.  
하루에 최대 100,000명의 users deactivation 가능.

> [!NOTE]  
> GitLab에서 생성된 bots는 휴면 users 자동 deactivation 대상에서 제외.

<hr>

## 참고
- **휴면 users 자동 deactivation** - https://docs.gitlab.com/ee/administration/moderate_users.html#automatically-deactivate-dormant-users
