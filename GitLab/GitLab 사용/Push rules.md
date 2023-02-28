# Push rules

<br>

User-friendly interface에서 활성화할 수 있는 **pre-receive Git hooks**  
Repository에 push할 수 있는 항목과 push할 수 없는 항목을 더 잘 제어할 수 있도록 하는 기능  
**Users, commit messages, branch names, files**로 제어 가능

Custom push rules를 사용하려면 [Git server hooks](https://github.com/bigmtn1113/GitLab-Note/blob/master/GitLab/GitLab%20%EA%B4%80%EB%A6%AC/Git%20server%20hooks.md) 이용

<br>

## Global push rules
모든 projects에 적용할 push rules 생성 가능  
[project level](https://docs.gitlab.com/ee/user/project/repository/push_rules.html#override-global-push-rules-per-project) 또는 [group level](https://docs.gitlab.com/ee/user/group/access_and_permissions.html#group-push-rules)로 재정의 가능

### 전제 조건
Administrator

### 설정 방법
1. 상단 표시줄에서 **Main menu > Admin** 선택
2. 왼쪽 사이드바에서 **Push Rules** 선택
3. **Push rules** 확장
4. 원하는 규칙 설정
5. **Save push rules** 선택

<br>

## Files 유효성 검사

### Prevent pushing secret files
**Credential files**와 **SSH private keys**와 같은 secrets를 version controle system에 commit하는 것을 방지

#### 차단된 파일 목록
- AWS CLI credential blobs
- Private RSA SSH keys
- Private DSA SSH keys
- Private ED25519 SSH keys
- Private ECDSA SSH keys
- Private ECDSA_SK SSH keys (GitLab 14.8 이상)
- Private ED25519_SK SSH keys (GitLab 14.8 이상)
- *.pem, *.key, *.history, *_history

※ 전체 기준 목록은 다음을 참고  
- [files_denylist.yml](https://gitlab.com/gitlab-org/gitlab/-/blob/master/ee/lib/gitlab/checks/files_denylist.yml?_gl=1%2a44221q%2a_ga%2aODY2NzMxODExLjE2NzczMTA1NzM.%2a_ga_ENFH3X7M5Y%2aMTY3NzMyMzg3NS4yLjEuMTY3NzMyNDk2Mi4wLjAuMA..)

<br>

## Example

### 특정 user만 push 허용
**Commit author's email**에서 정규 표현식을 통해 제한 가능

`ex) test@example\.co\.kr$`

test@example.co.kr만 push 허용  
(이메일의 식별 기준은 git config상의 user.email)

### 특정 branch로만 push 허용
**Branch name**에서 정규 표현식을 통해 제한 가능

`ex) dev`

dev branch만 push 허용  
(default branch는 무조건 push 허용)


### 특정 directory push 제한
**Prohibited file names**에서 정규표현식을 통해 제한 가능

`ex) ^directory-name/`

directory-name 하위 경로에 대한 push 제한

### 특정 files push 제한
**Prohibited file names**에서 정규표현식을 통해 제한 가능  
**or 연산** 활용

`ex) (^directory-name\/A\.txt|^directory-name\/B\.exe)$`

directory-name/A.txt, directory-name/B.exe push 제한

#### ※ 주의 사항
`git log`를 통해 관리 필요

예를 들어 A.txt를 push할 때 정책에 의해 reject되면 C.txt를 새로 push시,  
이전 A.txt commit이 처리되지 않아 C.txt push가 정상 작동하지 않을 가능성 존재

<hr>

## 참고
- **Push rules** - https://docs.gitlab.com/ee/user/project/repository/push_rules.html
