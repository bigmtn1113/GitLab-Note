# GitLab 가입한 user에게 email(gmail) 전송

<br>

## 1. GitLab UI 설정
### Admin - Settings - General에서 Sign-up restrictions 확장 후, Send confirmation email on sign-up 체크
![image](https://user-images.githubusercontent.com/46125158/181909276-8a2525b4-c6b5-4eee-ac2b-53da52796824.png)  
※ **Require admin approval for new sign-ups**를 체크하면 스스로 가입하지 못하고 admin이 승인을 해 줘야 함. 이러면 승인이 되어야 email이 전송됨

<br>

## 2. Google 계정의 앱 비밀번호 생성
### Google 계정 - 보안 - Google에 로그인 - 앱 비밀번호에서 앱 비밀번호를 생성할 앱 및 기기 선택
![image](https://user-images.githubusercontent.com/46125158/181908638-cade3f9f-ef0a-456a-8975-0b055fff9658.png)  
![image](https://user-images.githubusercontent.com/46125158/181908651-d0f59060-4cbb-4638-b89e-c1acf550cf45.png)  
생성된 비밀번호 저장  
※ 앱 비밀번호를 설정하려면 2단계 인증 사용이 활성화 되어 있어야 함

<br>

## 3. GitLab 설정 파일 수정 및 적용
### `/etc/gitlab/gitlab.rb` 파일 수정
```ruby
...
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.gmail.com"
gitlab_rails['smtp_port'] = 587
gitlab_rails['smtp_user_name'] = "<google email 주소>"
gitlab_rails['smtp_password'] = "<google 앱 비밀번호>"
gitlab_rails['smtp_domain'] = "smtp.gmail.com"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['smtp_tls'] = false
gitlab_rails['smtp_pool'] = false

###! **Can be: 'none', 'peer', 'client_once', 'fail_if_no_peer_cert'**
###! Docs: http://api.rubyonrails.org/classes/ActionMailer/Base.html
gitlab_rails['smtp_openssl_verify_mode'] = 'peer'
...
```

### 변경 사항 적용
```bash
sudo gitlab-ctl reconfigure
```

<br>

## 4. GitLab 메일 발송 테스트
### Rails Console 접속
```bash
sudo gitlab-rails console
```
※ Rails Console은 문제를 해결하거나 GitLab 애플리케이션의 직접 액세스를 통해서만 수행할 수 있는 일부 데이터를 검색해야 하는 GitLab 시스템 관리자를 위한 것

### 테스트 메일 전송
```ruby
Notify.test_email('<이메일 주소>', '<제목>', '<내용>').deliver_now
```

<br>

## 5. Email 수신 확인
![image](https://user-images.githubusercontent.com/46125158/181909077-a36128ff-683f-4761-b898-a98970081c73.png)

<br>

## 6. 회원 가입 후, Email 수신 확인
![image](https://user-images.githubusercontent.com/46125158/181909093-3cbe36d9-ebd7-437c-a1f4-dce4d1e40d9d.png)

<hr>

## 참고
- **Google 앱 비밀번호** - https://support.google.com/accounts/answer/185833?hl=ko
- **Rails Console** - https://docs.gitlab.com/ee/administration/operations/rails_console.html
- **Omnibus GitLab reconfigure** - https://docs.gitlab.com/ee/administration/restart_gitlab.html#omnibus-gitlab-reconfigure
