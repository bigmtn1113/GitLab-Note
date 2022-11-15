# GitLab CI/CD variables

<br>

CI/CD 변수는 환경 변수의 일종
- jobs 및 pipelines의 동작을 제어
- 재사용하려는 값을 저장
- `.gitlab-ci.yml` 파일에서 hard-coding 방지

Predefined CI/CD 변수나 다음과 같은 Custion CI/CD 변수 사용 가능
- `.gitlab-ci.yml` 파일의 변수
- Project CI/CD 변수
- Group CI/CD 변수
- Instance CI/CD 변수

<br>

## Predefined CI/CD 변수
GitLab CI/CD에는 pipelines 구성 및 job scripts에서 사용할 수 있는 [predefined CI/CD 변수의 기본 세트 존재](https://docs.gitlab.com/ee/ci/variables/predefined_variables.html)

### 변수 사용
Predefined CI/CD 변수를 `.gitlab-ci.yml`에서 먼저 선언하지 않고 사용 가능

#### Example
```yaml
test_variable:
  stage: test
  script:
    - echo "$CI_JOB_STAGE"
```

#### Result
```bash
$ echo $CI_JOB_STAGE
test
```

<br>

## Custom CI/CD 변수
### `.gitlab-ci.yml`의 변수
`variables` 키워드 사용

job 또는 `.gitlab-ci.yml` 파일의 최상위 수준에서 사용 가능  
job에 정의된 경우 해당 job에서만 사용 가능하나 `.gitlab-ci.yml` 파일의 최상위 수준에서 사용하면 전역적으로 사용 가능

#### Example
```yaml
variables:
  TEST_VAR: "All jobs can use this variable's value"

test-job:
  variables:
    TEST_VAR_JOB: "Only test-job can use this variable's value"
  script:
    - echo "$TEST_VAR" and "$TEST_VAR_JOB"
```

#### Result
```bash
$ echo "$TEST_VAR" and "$TEST_VAR_JOB"
All jobs can use this variable's value and Only test-job can use this variable's value
```

### Project CI/CD 변수
프로젝트 설정에 CI/CD 변수 추가 가능  
Maintainer 역할이 있는 프로젝트 구성원만 프로젝트 CI/CD 변수를 추가하거나 업데이트 가능

CI/CD 변수를 비밀로 유지하려면 `.gitlab-ci.yml`파일이 아닌 프로젝트 설정에 넣을 것

#### 절차
1. 해당 project에서 **Settings > CI/CD**로 이동하여 **Variables** 섹션 확장
2. **Add variable** 클릭 후 세부 정보 입력
    - **Key**: 한 줄이어야 하며 공백 없이 문자, 숫자 또는 `_`
    - **Value**: 제한 없음
    - **Type**: File 또는 Variable
    - **Environment scope**: 선택 사항. `All` 또는 특정 environments
    - **Protect variable**: 선택 사항. protected branches 또는 protected tags에서 실행되는 pipeline에서만 사용 가능
    - **Mask variable**: 선택 사항. 변수의 값을 job 로그에서 마스킹 처리

#### Example
![image](https://user-images.githubusercontent.com/46125158/201914647-6b8952a1-ba45-4d76-a2de-2b2f30cf8f6e.png)

```yaml
test-job:
  stage: test
  script:
    - echo "$PROJECT_VAR"
```

**Result**  
```bash
$ echo "$PROJECT_VAR"
project's variable
```

### Group CI/CD 변수
그룹의 모든 프로젝트에서 CI/CD 변수 사용 가능  
Group owner만 그룹 수준 CI/CD 변수를 추가하거나 업데이트 가능

#### 절차
1. 해당 group에서 **Settings > CI/CD**로 이동
2. **Add variable** 클릭 후 세부 정보 입력
    - **Key**: 한 줄이어야 하며 공백 없이 문자, 숫자 또는 `_`
    - **Value**: 제한 없음
    - **Type**: File 또는 Variable
    - **Environment scope**: 선택 사항. `All` 또는 특정 environments
    - **Protect variable**: 선택 사항. protected branches 또는 protected tags에서 실행되는 pipeline에서만 사용 가능
    - **Mask variable**: 선택 사항. 변수의 값을 job 로그에서 마스킹 처리

#### 프로젝트에서 사용 가능한 모든 그룹 수준 변수 보기
1. 해당 project에서 **Settings > CI/CD**로 이동
2. **Variables** section 확장

※ Subgroups의 변수는 재귀적으로 상속  
![inherited_group_variables_v12_5](https://user-images.githubusercontent.com/46125158/201919267-71e699d8-c610-4cad-9a67-9d32fdd72586.png)

### Instance CI/CD 변수
GitLab 인스턴스의 모든 프로젝트 및 그룹에서 CI/CD 변수 사용 가능  
Administrator만 CI/CD 변수를 추가하거나 업데이트 가능

#### 절차
1. 상단 표시줄에서 **Main Menu > Admin** 선택
2. 왼쪽 사이드바에서 **Settings > CI/CD**로 이동하여 **Variables** 섹션 확장
3. **Add variable** 클릭 후 세부 정보 입력
    - **Key**: 한 줄이어야 하며 공백 없이 문자, 숫자 또는 `_`
    - **Value**: GitLab 13.3 이상에서는 10,000자 허용. 선택한 runner OS의 한계에 의해 제한될 수 있음
    - **Type**: File 또는 Variable
    - **Protect variable**: 선택 사항. protected branches 또는 protected tags에서 실행되는 pipeline에서만 사용 가능
    - **Mask variable**: 선택 사항. 변수의 값을 job 로그에서 마스킹 처리

<hr>

## 참고
- **GitLab CI/CD 변수** - https://docs.gitlab.com/ee/ci/variables/
