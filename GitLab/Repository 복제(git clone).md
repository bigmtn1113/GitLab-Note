# Repository 복제(git clone)

<br>

## 요구 사항
- **Git 설치**
- **Git 구성**  
  컴퓨터에서 Git 사용을 시작하려면 자격 증명을 입력하여 자신을 작업 작성자로 식별해야 하며, 사용자 이름과 이메일 주소는 GitLab에서 사용하는 것과 일치해야 함
  ```bash
  git config --global user.name "your_username"
  git config --global user.email "your_email_address@example.com"
  
  # 구성 확인
  git config --global --list
  ```
  
  `--global` 옵션은 시스템에서 수행하는 모든 작업에 항상 이 정보를 사용하도록 Git에 지시
  
  다른 옵션 참고: https://github.com/kva231/GitLab-Note/blob/master/Git/git%20config.md

<hr>

## Repository 복제
SSH 또는 HTTPS 사용 가능하나, SSH 권장

### SSH로 복제
1. 
2. Project로 이동 후, **Clone** 클릭. **Clone with SSH**에 대한 URL 복사
3. **git clone** 실행  
  ```bash
  git clone git@gitlab.com:gitlab-tests/sample-project.git
  ```
4. Project 명과 동일한 이름의 디렉터리로 이동해 파일 확인  
  ```bash
  cd sample-project
  ```

### HTTPS로 복제
1. Project로 이동 후, **Clone** 클릭. **Clone with HTTPS**에 대한 URL 복사
2. **git clone** 실행  
  ```bash
  git clone https://gitlab.com/gitlab-tests/sample-project.git
  ```
3. **username 및 password** 입력  
  계정에 대해 **2FA**를 활성화한 경우, 계정 암호 대신 `read_repository` 또는 `write_repository` 권한이 있는 Personal Access Token을 사용  
  **2FA**를 활성화하지 않은 경우, 계정 암호 사용
4. Project 명과 동일한 이름의 디렉터리로 이동해 파일 확인  
  ```bash
  cd sample-project
  ```

<hr>

## 참고
- **Command line Git** - https://docs.gitlab.com/ee/gitlab-basics/start-using-git.html
- **SSH 키를 사용하여 GitLab과 통신** - https://docs.gitlab.com/ee/user/ssh.html
