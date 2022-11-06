# Projects API

<br>

## 전제 조건
**Personal access token**의 scope: `api` 혹은 `read_api`

<br>

## Project visibility level
- `private`: 프로젝트 액세스는 각 사용자에게 명시적으로 부여
- `internal`: External users를 제외한 로그인한 모든 사용자가 액세스 가능
- `public`: 인증 없이 액세스 가능

<br>

## All projects list 출력
인증된 사용자에 대해 GitLab에서 볼 수 있는 모든 projects 목록 조회. 인증 없이 액세스하면 public projects의 simple 필드만 반환

### Attribute
속성을 사용해 원하는 목록 조회 가능

- **id_after, id_before**
  - 지정한 ID보다 큰, 작은 ID를 가진 projects 반환
  - ex) id_after=100&id_before=200
- **imported**
  - 현재 사용자가 외부 시스템에서 가져온 projects 반환
  - ex) imported=true
- **last_activity_after, last_activity_before**
  - 지정한 시간 이후, 이전에 last_activity가 있는 projects 반환
  - ISO 8601(`YYYY-MM-DDTHH:MM:SSZ`) 형식
  - ex) last_activity_after=2022-10-10&last_activity_before=2022-10-29
- **membership**
  - 현재 사용자가 속한 projects 반환
  - ex) membership=true
- **order_by**
  - Projects 정렬 기준 지정
  - 값: `id`, `name`, `path`, `created_at`, `updated_at`, `last_activity_at`, `similarity`
  - ex) order_by=name
- **owned**
  - 현재 사용자가 명시적으로 소유한 projects 반환
  - ex) owned=true
- **simple**
  - 각 project에 대해 제한된 필드만 반환
  - 인증 없이 simple=false 사용 불가(인증 시 default: `false`)
  - ex) simple=true
- **sort**
  - `asc` 또는 `desc` 순으로 projects 정렬(default: `desc`)
  - ex) sort=desc
- **visibility**
  - 가시성 제한
  - 값: `public`, `internal`, `private`
  - ex) visibility=private

### 기본 형식
```bash
curl --request GET "https://<GitLab domain>/api/v4/projects"

# 인증된 사용자 사용
curl --header "PRIVATE-TOKEN: <Personal access token>" "https://<GitLab domain>/api/v4/projects"
```

### 사용 예시
2022-10-10부터 2022-10-29사이에 마지막 활동이 일어난 Private projects를 제한된 필드만 조회

```bash
curl -s --header "PRIVATE-TOKEN: <Personal access token>" "https://<GitLab domain>/api/v4/projects?last_activity_after=2022-10-10&last_activity_before=2022-10-29&visibility=private&simple=true"
```

<hr>

## 참고
- **Projects API** - https://docs.gitlab.com/ee/api/projects.html
