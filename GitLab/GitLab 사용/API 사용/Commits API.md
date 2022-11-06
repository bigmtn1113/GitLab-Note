# Commits API

<br>

## 전제 조건
**Personal access token**의 scope: `api` 혹은 `read_api`

<br>

## Repository commits list 출력
### Attribute
속성을 사용해 원하는 목록 조회 가능

- **ref_name**
  - repository 브랜치 이름
  - ex) ref_name=main
- **since, until**
  - 지정된 날짜 이후, 이전에 발생한 commits 발환
  - ISO 8601(`YYYY-MM-DDTHH:MM:SSZ`) 형식
  - ex) since=2022-10-10&until=2022-10-29
- **path**
  - 파일 경로
  - ex) path=text.txt
- **all**
  - repository의 모든 commit 검색
  - ex) all=true

### 기본 형식
```bash
curl --header "PRIVATE-TOKEN: <Personal access token>" "https://<GitLab domain>/api/v4/projects/<Project ID>/repository/commits"
```

### 사용 예시
2022-10-10부터 2022-10-29사이에 발생한 main 브랜치의 text.txt 파일 commits 이력 조회
```bash
curl -s --header "PRIVATE-TOKEN: <Personal access token>" "https://<GitLab domain>/api/v4/projects/<Project ID>/repository/commits?ref_name=main&path=text.txt&since=2022-10-10&until=2022-10-29
```

<hr>

## 참고
- **Commits API** - https://docs.gitlab.com/ee/api/commits.html
