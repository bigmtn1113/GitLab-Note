# GitLab Container Registry 사용

<br>

통합 Container Registry를 사용하여 각 GitLab 프로젝트의 컨테이너 이미지 저장 가능  
GitLab Container Registry 활성화 후 진행

<br>

## Container images naming 규칙
```bash
<registry URL>/<namespace>/<project>/<image>
```

만약 project가 `<GitLab URL>/mynamespace/myproject`라면 container image는 `<registry URL>/mynamespace/myproject`여야 하며 container image 이름 끝에 최대 two levels deep까지 이름 추가 가능

#### Example
```bash
registry.example.com/mynamespace/myproject:some-tag
registry.example.com/mynamespace/myproject/image:latest
registry.example.com/mynamespace/myproject/my/image:rc1
```

<hr>

## 참고
- **Container images naming 규칙** - https://docs.gitlab.com/ee/user/packages/container_registry/#naming-convention-for-your-container-images
