# SSH 키를 사용하여 GitLab과 통신

<br>

## 전제 조건
- GNU/Linux, macOS 및 Windows 10에 사전 설치된 **OpenSSH** 클라이언트
- SSH 버전 6.5 이상(이전 버전에서는 안전하지 않은 MD5 서명 사용)

※ SSH 버전 확인  
```bash
ssh -V
```

※ SSH 키는 안전성 및 성능 측에서 **RSA** 보다 **ED25519** 사용 권장. **RSA**를 사용하는 경우 최소 2048bit 키 크기 권장

<hr>

## SSH key pair 생성
### ED25519
```bash
ssh-keygen -t ed25519

# SSH 키를 저장할 위치 지정
Generating public/private ed25519 key pair.
Enter file in which to save the key (/home/user/.ssh/id_ed25519):

# Passphrase 지정
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
```

※ **Passphrase 지정**  
암호를 모르는 사람이 개인 키를 사용하지 못 하도록 보호. SSH 연결할 때마다 암호를 입력해야 하니 자동 로그인을 원할 시, 생략

### 지정한 경로에서 생성된 파일 확인
```bash
ls ~/.ssh/

# id_ed25519.pub    id_ed25519
```

<br>

## GitLab 계정에 SSH 키 추가
### 공개 키 파일 내용 복사
```bash
cat ~/.ssh/id_ed25519.pub
```

### GitLab에 SSH 키 등록
**User Settings > SSH Keys**로 이동 후, **Key**란에 복사한 내용 입력하고 **Add key** 버튼 클릭  
※ **만료 날짜**는 선택 사항  
![image](https://user-images.githubusercontent.com/46125158/184799488-f40d92bf-d432-4b05-a532-bc92f3907e82.png)

### 확인 및 연결 테스트
**User Settings > SSH Keys > Your SSH keys**  
![image](https://user-images.githubusercontent.com/46125158/184799213-75b24f73-1d46-4f1b-a36e-bcdf99c6d525.png)

```bash
# 연결 테스트
# gitlab.example.com은 GitLab 인스턴스 URL로 변경
ssh -T git@gitlab.example.com

The authenticity of host 'gitlab.example.com (35.231.145.151)' can't be established.
ECDSA key fingerprint is SHA256:HbW3g8zUjNSksFbqTiUWPWg2Bq1x8xdGUrliXFzSnUw.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'gitlab.example.com' (ECDSA) to the list of known hosts.

# Welcome to GitLab, @username! 출력 확인
```

<hr>

## 참고
- **SSH 키를 사용하여 GitLab과 통신** - https://docs.gitlab.com/ee/user/ssh.html
- **What is Passphrase** - https://www.ssh.com/academy/ssh/passphrase
