# User 비밀번호 재설정

<br>

## UI 사용
1. 상단표시줄에서 **Main menu > Admin** 선택
2. **Overview > Users** 선택
3. 비밀번호를 업데이트하려는 사용자 선택 후, **Edit** 선택
4. **Password** area에서 Password, Password confirmation란에 비밀번호 입력
5. **Save changes** 선택

<br>

## Rake task 사용
```bash
$ sudo gitlab-rake "gitlab:password:reset"

Enter username:
Enter password:
Confirm password:
```

username, password, password 확인까지 모두 입력

<hr>

## 참고
- **Reset a user’s password** - https://docs.gitlab.com/ee/security/reset_user_password.html
