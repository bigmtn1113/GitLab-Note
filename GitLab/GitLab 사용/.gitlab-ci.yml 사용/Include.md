# Include

<br>

CI/CD jobs에 외부 YAML files을 포함하는 데 `include` 사용 가능.

<br>

## 단일 구성 file include
명시한 file이 local file이면 `include:local`로, remote file이면 `include:remote`처럼 작동.

```yaml
include: '/templates/.gitlab-ci-template.yml'
```

<br>

## 배열 구성 files include
`include` 유형을 지정하지 않으면, 각 배열 항목의 기본값은 필요에 따라 `include:local` 또는 `include:remote`로 작동.

```yaml
include:
  - 'https://gitlab.com/awesome-project/raw/main/.before-script-template.yml'
  - '/templates/.gitlab-ci-template.yml'
```

다음과 같이 지정 가능.  
```yaml
include:
  - remote: 'https://gitlab.com/awesome-project/raw/main/.before-script-template.yml'
  - local: '/templates/.gitlab-ci-template.yml'
```

<br>

## `include`
하나의 긴 `.gitlab-ci.yml` file을 여러 files로 분할하여 가독성을 높이거나, 여러 위치에서 동일한 구성의 중복 줄이기 가능.  
Template files를 중앙 repository에 저장하고 projects에 포함 가능.

### `include:local`
`include:local` keyword가 포함된 구성 file과 동일한 repository 및 branch에 있는 file을 포함하는 데 사용.

```yaml
include:
  - local: '/templates/.gitlab-ci-template.yml'
```

또는

```yaml
include: '/templates/.gitlab-ci-template.yml'
```

<br>

### `include:project`
동일한 GitLab instance에 있는 다른 private project의 files를 포함하려면 `include:project` 및 `include:file`를 사용.

```yaml
include:
  - project: 'my-group/my-subgroup/my-project'
    ref: main
    file:
      - '/templates/.builds.yml'
      - '/templates/.tests.yml'
```

- `include:project`: GitLab project의 전체 경로.
- `include:file`: Root directory(`/`)를 기준으로 하는 전체 file 경로 또는 file 경로 배열.
- `include:ref`: 선택사항. file을 검색할 참조. 지정되지 않은 경우 기본값은 project의 `HEAD`. ex) main, v1.0.0, 78712xxx~(Git SHA)

<br>

### `include:remote`
다른 위치의 file을 포함하려면 전체 URL과 함께 `include:remote` 사용.

```yaml
include:
  - remote: 'https://gitlab.com/example-project/-/raw/main/.gitlab-ci.yml'
```

<br>

### `include:template`
[.gitlab-ci.yml templates](https://gitlab.com/gitlab-org/gitlab/-/tree/master/lib/gitlab/ci/templates)를 포함하려면 `include:template` 사용.

```yaml
include:
  - template: Android-Fastlane.gitlab-ci.yml
  - template: Auto-DevOps.gitlab-ci.yml
```

<hr>

## 참고
- **다른 파일의 CI/CD 구성 사용** - https://docs.gitlab.com/ee/ci/yaml/includes.html
- **include** - https://docs.gitlab.com/ee/ci/yaml/index.html#include
