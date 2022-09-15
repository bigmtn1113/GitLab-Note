# GitLab 관리 시작하기

<br>

## 인증
- 모든 사용자에 대해 2단계 인증(2FA) 시행
- 사용자가 다음을 수행하는지 확인
  - 강력하고 안전한 암호 사용 여부
  - 2FA 활성화 여부
  - Recovery Codes 저장 여부
    - 인증 장치에 액세스할 수 없는 경우 recovery code를 사용해 GitLab 로그인 가능
  - SSH키 추가 여부
    - SSH키를 이용해 새 recovery codes 생성 가능
  - Personal Access Token 활성화 여부
    - 이 토큰을 사용해 GitLab API 액세스 가능

<br>

## GitLab 인스턴스 보안 모범 사례
### 액세스 기본 사항
#### SSH 설정
- 특정 표준 그룹에서는 이전 DSA보다 RSA, ECDSA, ED25519, ECDSA_SK 또는 ED25519_SK를 사용할 것을 권장
  - RSA 키보다 **ED25519** 키를 권장하나, RSA 키를 사용하는 경우 최소 **2048비트**의 키 크기 권장
- GitLab을 사용하면 허용되는 SSH 키 기술을 제한하고 각 기술에 대한 최소 키 길이를 지정 가능
  - **Main menu > Admin > Settings > General** 선택 후, **Visibility and access controls** 섹션 확장

### 방법 및 대상 제한
**Admin Area > Settings > General**에서 확인

#### 가입 제한
- **신규 가입(Sign-up enabled)** 비활성화 여부 확인
  - GitLab 13.6 이상이 설치된 자체 관리형 인스턴스에서는 기본적으로 비활성화  
- **이메일 확인(Send confirmation email on sign-up)** 활성화 여부 확인
  - 실제 사용자인지 확인 가능
- **최소 암호 길이** 값을 12 이상의 값으로 설정
  - 길이 뿐만 아니라 복잡성 요구 사항(숫자, 대문자, 소문자 및 기호) 선택 가능
- ****이메일 도메인 허용 목록(Allowed domains for sign-ups)**** 작성
  - 주어진 도메인 목록과 일치하는 이메일 주소를 사용하여 가입하도록 사용자 제한 가능
  - ex) example.com

#### 로그인 제한
- 2FA 활성화 확인
- 특정 이유로 MFA 사용이 불가할 경우, **Allow password authentication for Git over HTTP(S)** 비활성화
  - 개인 액세스 토큰 또는 LDAP 암호를 사용하여 인증

#### 가시성 및 개인 정보 보호
- **Default project visibility**이 Private인지 확인
  - 비공개 프로젝트는 프로젝트 구성원만 복제, 다운로드 또는 볼 수 있으며 새로 등록된 사용자는 이러한 프로젝트에 액세스 불가

<hr>

## 참고
- **GitLab instance: security best practices** - https://about.gitlab.com/blog/2020/05/20/gitlab-instance-security-best-practices/?_gl=1*1kticzx*_ga*MzUwOTcyMjgyLjE2NjMyMDQzMTE.*_ga_ENFH3X7M5Y*MTY2MzIxNTkzNC4yLjEuMTY2MzIyMTA4OC4wLjAuMA
