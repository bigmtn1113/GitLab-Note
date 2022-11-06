# Groups API

<br>

## 전제 조건
**Personal access token**의 scope: `api` 혹은 `read_api`

<br>

## Group visibility level
- `private`: 그룹 및 해당 프로젝트는 members만 조회 가능
- `internal`: 그룹 및 모든 internal 프로젝트는 External users를 제외한 로그인한 모든 사용자가 조회 가능
- `public`: 그룹 및 모든 public 프로젝트는 인증 없이 조회 가능

<br>

## Groups list 출력
인증된 사용자에 대해 표시되는 그룹 목록 조회. 인증 없이 액세스하면 public groups만 반환

### Attribute
속성을 사용해 원하는 목록 조회 가능

- **order_by**
  - Groups 정렬 기준 지정
  - 값: `name`, `path`, `id`, `similarity`(default: `name`)
  - ex) order_by=name
- **sort**
  - `asc` 또는 `desc` 순으로 groups 정렬(default: `asc`)
  - ex) sort=desc
- **owned**
  - 현재 사용자가 명시적으로 소유한 groups 반환
  - ex) owned=true

### 기본 형식
```bash
curl --request GET "https://<GitLab domain>/api/v4/groups"

# 인증된 사용자 사용
curl --header "PRIVATE-TOKEN: <Personal access token>" "https://<GitLab domain>/api/v4/groups"
```

### 사용 예시
현재 사용자가 명시적으로 소유한 groups를 id 기준으로 내림차순 정렬해서 조회

```bash
curl -s --header "PRIVATE-TOKEN: <Personal access token>" "https://<GitLab domain>/api/v4/groups?owned=true&order_by=id&sort=desc"
```

<hr>

## 참고
- **Groups API** - https://docs.gitlab.com/ee/api/groups.html
