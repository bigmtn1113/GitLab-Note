# Jira

조직에서 Jira issues를 사용하는 경우, Jira에서 issues를 migration하고 GitLab에서만 작업 가능  
그러나 Jira를 계속 사용하려면 GitLab과 통합 가능

<br>

## Jira integration
하나 이상의 GitLab projects를 Jira instance에 연결  
Jira instance를 직접 hosting하거나 Atlassian Cloud에서 hosting 가능  
지원되는 Jira version은 `6.x`, `7.x`, `8.x`및 `9.x`

### Jira Cloud API token 생성
Atlassian Cloud에서 Jira와 integration하려면 API token을 생성 필요

1. Jira projects에 대한 **write** access 권한이 있는 계정에서 [Atlassian](https://id.atlassian.com/manage-profile/security/api-tokens)에 login 진행  
    Link는 **API tokens** page를 open. 또는 Atlassian profile에서 **Account Settings > Security > Create and manage API tokens**를 선택
2. **Create API token** 선택
3. 대화 상자에서 token label을 입력하고 **Create** 선택

API token을 복사하려면 **Copy**를 선택하고 token을 안전한 곳에 paste 진행

이후 GitLab을 구성하려면 다음 정보 필요
- 새로 생성된 token
- Token을 만들 때 사용한 email 주소

### Integration 구성
GitLab에서 project 설정을 구성하여 Jira integration 활성화 가능. 다음 위치에서도 이러한 설정을 구성 가능
- Group 수준
- 자체 관리형 GitLab의 instance 수준

#### 전제 조건
- GitLab 설치에서 상대 URL(ex. `https://example.com/gitlab`)을 사용하지 않는지 확인
- **Jira Server** 의 경우, Jira username과 password가 있는지 확인
- **Jira Cloud** 의 경우, token을 만드는데 사용한 API toekn과 email 주소가 있는지 확인

#### Project 설정 구성
1. 상단 표시줄에서 **Main menu > Projects**를 선택하고 project 찾기
2. 왼쪽 sidebar에서 **Settings > Integrations** 선택
3. **Jira** 선택
4. **Enable integration** 선택
5. **Trigger** 작업을 선택. 선택에 따라 Jira issue(GitLab commit, merge request 또는 둘 다)에 대한 언급이 Jira에서 다시 GitLab에 대한 cross-link를 생성할지 여부가 결정
6. GitLab에서 **Trigger** 작업이 수행될 때 Jira issue에 댓글을 달려면 **Enable comments** 선택
7. GitLab에서 종료 참조(자동으로 issue 종료)가 생성될 때 Jira issue를 전환하려면 **Enable Jira transitions** 선택
8. Jira 구성 정보 제공:
    - **Web URL** : 이 GitLab project에 연결하는 Jira instance web interface의 기본 URL(ex. `https://jira.example.com`)
    - **Jira API URL** : Jira instance API에 대한 기본 URL(ex. `https://jira-api.example.com`). 설정하지 않은 경우 기본값은 **Web URL** 값. **Atlassian Cloud의 Jira**를 사용하는 경우 공백
    - **Username 또는 Email** : **Jira Server** 의 경우, `username` 사용. **Atlassian Cloud의 Jira**의 경우, `email` 사용
    - **Pssword/API token** : **Jira Server**의 경우, `password` 사용. **Atlassian Cloud의 Jira**의 경우, `API token` 사용
9. 사용자가 GitLab project 내에서 Jira issues를 볼 수 있도록 하려면 **Enable Jira issues**를 선택하고 Jira project key 입력  
    지정된 GitLab project에서 단일 Jira project의 issues만 표시 가능  
    이 설정으로 Jira issues를 활성화하면 이 GitLab project에 대한 access 권한이 있는 모든 사용자가 지정된 Jira project의 모든 issues를 볼 수 있음
10. 취약점에 대한 issue 생성을 활성화하려면 **Enable Jira issue creation from vulnerabilities** 선택
11. **Jira issue type** 선택. dropdown 목록이 비어 있으면 새로 고침을 선택하고 다시 시도
12. Jira 연결이 작동하는지 확인하려면 **Test settings** 선택
13. **Save changes** 선택

이제 GitLab project가 instance의 모든 Jira projects와 상호 작용할 수 있으며 이제 project에 Jira project를 여는 Jira link가 표시됨

<br>

## Jira migration
GitLab Jira importer를 사용하여 Jira issues를 GitLab.com 또는 자체 관리형 GitLab instance로 import 가능

### 전제 조건
#### 권한
Jira project로부터 issues를 import하려면 Jira issues에 대한 read access 권한이 있어야 하며 최소한 가져오려는 GitLab project의 Maintainer 역할 필요

#### Jira integration
이 기능은 기존 GitLab Jira integration을 사용  
Jira issues를 import하기 전에 integration이 설정되어 있는지 확인

### Jira issues import
Jira issues import는 비동기 background job으로 수행되므로 import queues load, system load 또는 기타 요인에 따라 지연 발생 가능성 존재  
큰 projects를 import하는 경우 import 크기에 따라 몇 분 정도 시간이 소요될 가능성 존재

1. **Issues** page에서 **Import Issues > Import from Jira** 선택  
    **Import from Jira** option은 올바른 권한이 있는 경우에만 표시  
    이전에 Jira integration을 설정한 경우 dropdown 목록에서 access 권한이 있는 Jira projects를 볼 수 있음
2. dropdown 목록에서 **Import from**을 선택하고 issues를 import할 Jira project를 선택  
    **Jira-GitLab user mapping template** section의 table에는 Jira 사용자가 mapping된 GitLab 사용자가 표시  
    양식이 나타나면 dropdown 목록은 기본적으로 import를 수행하는 사용자로 지정
3. Mapping을 변경하려면 **GitLab username** 열에서 dropdown 목록을 선택하고 각 Jira 사용자에 mapping할 사용자를 선택  
    Dropdown 목록에 모든 사용자가 표시되지 않을 수 있으므로 검색 표시줄을 사용하여 해당 GitLab project에서 특정 사용자를 검색
4. **Continue** 선택. import가 시작되었다는 확인 message가 표시  
    import가 background에서 실행되는 동안 import 상태 page에서 issues page로 이동할 수 있으며 issues 목록에 나타나는 새 issues를 볼 수 있음
5. Import 상태를 확인하려면 Jira import page로 다시 이동

<hr>

## 참고
- **Jira** - https://docs.gitlab.com/ee/integration/jira/
- **Jira integration** - https://docs.gitlab.com/ee/integration/jira/configure.html
- **Jira import** - https://docs.gitlab.com/ee/user/project/import/jira.html
