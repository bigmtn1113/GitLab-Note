# extends

<br>

extends 키워드는 구성 섹션을 재사용하는데 사용  
다단계 상속을 지원하지만 3 depth 이상 사용하는 것은 지양. 최대 11 depth까지 사용 가능

include 키워드와 함께 사용 가능

<hr>

## `.gitlab-ci.yml` 파일 작성

### `.gitlab-ci.yml`
```yaml
image: ubuntu:latest

stages:
  - build
  - test

.extends-tags:        # .<name>
  tags:
    - SharedRunner

build-job:
  stage: build
  extends:
    - .extends-tags
  script:
    - echo "build stage"

test-job:
  stage: test
  extends:
    - .extends-tags
  script:
    - echo "test stage"
```

#### ※ extends 키워드 사용 유무 비교
```yaml
# 위의 build-job과 동일
build-job:
  stage: build
  tags:
    - SharedRunner
  script:
    - echo "build stage"
```

<br>

## 결과 확인

### Pipeline 확인
![image](https://user-images.githubusercontent.com/46125158/193399090-8a55f023-0319-4bd3-addc-16d46df17d9c.png)

<hr>

## 참고
- **extends** - https://docs.gitlab.com/ee/ci/yaml/#extends
- **extends detail** - https://docs.gitlab.com/ee/ci/yaml/yaml_optimization.html#use-extends-to-reuse-configuration-sections
