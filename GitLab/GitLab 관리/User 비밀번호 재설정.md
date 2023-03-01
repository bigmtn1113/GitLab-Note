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

<br>

## Rake console 사용
1. Rails console 시작
    ```bash
    sudo gitlab-rails console
    ```
2. User 찾기
    - Username으로 찾기
      ```bash
      user = User.find_by_username 'exampleuser'
      ```
    - User ID로 찾기
      ```bash
      user = User.find(123)
      ```
    - Email address로 찾기
      ```bash
      user = User.find_by(email: 'user@example.com')
      ```
3. 암호 재설정
    ```bash
    user.password = '<new_password>'
    user.password_confirmation = '<new_password>'
    ```
4. 변경 사항 저장
    ```bash
    user.save!
    ```
5. console 종료
    ```bash
    exit
    ```

<hr>

## 참고
- **Reset a user’s password** - https://docs.gitlab.com/ee/security/reset_user_password.html
