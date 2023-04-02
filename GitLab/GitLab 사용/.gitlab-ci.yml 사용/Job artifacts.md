# Job artifacts

<br>

Job은 files 및 directories의 archive를 output할 수 있는데 이 output을 job artifact라고 지칭  
GitLab UI 또는 API를 사용하여 job artifacts download 가능

<br>

## `.gitlab-ci.yml` 파일 작성

### `.gitlab-ci.yml`
```yaml
stages:
  - test

artifacts-job:
  stage: test
  script:
    - echo "Save artifacts" >> test.txt
  artifacts:
    name: "$CI_JOB_NAME-test-file"
    paths:
      - test.txt

use-artifacts-job:
  stage: test
  script:
    - echo "Use artifacts"
    - cat test.txt
```

CI/CD 변수를 사용하여 artifacts files의 이름을 동적으로 정의 가능  
ex) `name: "$CI_JOB_NAME-test-file"`

<br>

## 결과 확인

### Pipeline 확인
![image](https://user-images.githubusercontent.com/46125158/229338348-209cd1c8-5476-420a-9b13-cfc0eca6f797.png)

### Jobs 확인
#### artifacts-job
![image](https://user-images.githubusercontent.com/46125158/229338655-6fc40dd3-6a12-410e-a6e7-090707586924.png)

#### use-artifacts-job
![image](https://user-images.githubusercontent.com/46125158/229338739-4fcc8f85-9890-4822-a67b-d8b952b321e6.png)

#### Job artifacts download
![image](https://user-images.githubusercontent.com/46125158/229338818-7676c144-4304-4067-b1fd-638468b98ad8.png)

![image](https://user-images.githubusercontent.com/46125158/229338827-078707c7-4e33-4098-88e5-e0335a30ef0d.png)  
`.gitlab-ci.yml`에 작성한 artifacts의 이름대로 file 이름이 지정된 것 확인 가능

<hr>

## 참고
- **Job artifacts** - https://docs.gitlab.com/ee/ci/pipelines/job_artifacts.html
