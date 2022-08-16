# RSSH 키를 사용하여 GitLab과 통신

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


<hr>

## 참고
- **SSH 키를 사용하여 GitLab과 통신** - https://docs.gitlab.com/ee/user/ssh.html
- **What is Passphrase** - https://www.ssh.com/academy/ssh/passphrase
