# git clone 및 git push

<br>

## 시나리오
test_group이란 group 아래에 다음과 같은 project가 2개 구성된 상태
- test_project_src
- test_project_dest

1. test_project_src project에서 test_project_dest project를 git clone
2. test_project_dest project로 push할 내용 작성
3. test_project_src project에서 test_project_dest project로 git push

※ group 생성은 선택사항. project 2개만 존재하면 구현 가능

<br>

## 전제 조건
- (선택)test_group 생성
- test_group 밑에 Project 2개(test_project_src, test_project_dest) 생성
- test_project_src에 gitlab runner 등록

<hr>

## Access Token 생성 및 사용
### test_project_dest의 **Project Access Token** 생성
1. **Settings > Access Tokens** 선택
2. 내용 작성
    - **Select a role** - Maintainer
    - **Scopes** - write_repository
    
    ※ role은 protected branches(main)에 push 하기 위해 지정. non-protected branches에 push 하려면 Developer 권한으로도 가능

![image](https://user-images.githubusercontent.com/46125158/199913220-05a456b8-e371-408a-86e4-8ab1f56e25d5.png)

### test_project_src에 **CI/CD 변수** 등록 - **Settings > CI/CD > Variables 섹션 확장**  
- **Key:** PROJECT_ACCESS_TOKEN  
  ※ Key 이름은 자유롭게 지정 가능
- **Value:** 생성한 Project Access Token 값 입력

![image](https://user-images.githubusercontent.com/46125158/199914947-6e56bdb0-f56f-428f-9eb0-7ae6a2b7c875.png)  

<br>

## test_projcet_src에 `.gitlab-ci.yml` 파일 작성
### `.gitlab-ci.yml`
```yaml
image: alpine:latest
stages:
  - deploy

# 파이프라인 전체 동작 제어
# .gitlab-ci.yml 파일이 수정 되었을 때만 파이프라인 실행
workflow:
  rules:
    - changes:
      - .gitlab-ci.yml

variables:
  dest: test_project_dest

deploy:
  stage: deploy
  tags:
    - SharedRunner
  before_script:
    - apk add git
    - git config --global user.email "gitlab@noreply.gitlab.example.com" && git config --global user.name "gitlab-ci runner"
  script:
    - git clone https://gitlab-ci-token:${CI_JOB_TOKEN}@gitlab.example.com/test_group/$dest.git && cd $dest
    - touch test.txt
    - git add test.txt && git commit -m "Gitlab-CI runner $CI_COMMIT_SHORT_SHA"
    - git push "https://gitlab-ci-token:${PROJECT_ACCESS_TOKEN}@gitlab.example.com/test_group/$dest.git" main
```
- **CI_JOB_TOKEN** - 특정 API 엔드포인트로 인증하기 위한 토큰이며, 작업이 실행되는 동안 유효. 파이프라인 작업이 실행될 때 GitLab은 고유한 토큰을 생성하고 이를 미리 정의된 변수 CI_JOB_TOKEN로 주입

### ※ git clone
본 내용에서는 project 소유자가 같으므로 참고만 할 것

git clone 시 clone 대상 project가 public이 아닐 경우, pipeline 실행자는 대상 project의 최소 Reporter 이상의 권한을 소유한 member여야 함  
자체 관리형 GitLab 인스턴스에서 Guest 사용자는 public 및 internal project에서만 작업 수행 가능. private project는 최소 Reporter 권한 필요

![image](https://user-images.githubusercontent.com/46125158/199920439-6ab5bf97-3c08-42f7-b8b8-6401bbb29488.png)  
![image](https://user-images.githubusercontent.com/46125158/199923038-4dd9956a-3568-47c6-b300-b510c49d2283.png)

<br>

## 결과 확인
### test_projcet_src repository
![image](https://user-images.githubusercontent.com/46125158/184539983-fc87121f-35a0-4b67-8163-6de086b656f4.png)

### Pipeline 확인
![image](https://user-images.githubusercontent.com/46125158/184540774-70557ea7-73ed-47e2-9eb4-6156309da620.png)

### test_project_dest에서 push된 내용 확인
![image](https://user-images.githubusercontent.com/46125158/184539615-5b4d2932-0acf-40e1-8215-b434d09d93c6.png)

<hr>

## 참고
- **Permissions and roles** - https://docs.gitlab.com/ee/user/permissions.html
- **CI_JOB_TOKEN** - https://docs.gitlab.com/ee/ci/jobs/ci_job_token.html
- **Predefined variables reference** - https://docs.gitlab.com/ee/ci/variables/predefined_variables.html
- **Project access tokens** - https://docs.gitlab.com/ee/user/project/settings/project_access_tokens.html
