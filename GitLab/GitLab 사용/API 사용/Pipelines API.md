# Pipelines API

<br>

## 전제 조건
**Personal access token**의 scope: `api` 혹은 `read_api`

<br>

## Project pipelines list 출력
### Attribute
속성을 사용해 원하는 목록 조회 가능

- **status**
  - pipelines의 상태
  - 값: `created`, `waiting_for_resource`, `preparing`, `pending`, `running`, `success`, `failed`, `canceled`, `skipped`,`manualscheduled`
  - ex) status=success
- **ref**
  - pipelines가 실행되는 브랜치
  - ex) ref=main
- **username**
  - pipelines를 트리거한 사용자의 username
  - ex) username=bigmtn
- **updated_after, updated_before**
  - 지정된 날짜 이후, 이전에 업데이트된 pipelines 반환
  - ISO 8601(`YYYY-MM-DDTHH:MM:SSZ`) 형식
  - ex) updated_after=2022-10-10&updated_before=2022-10-29
- **order_by**
  - Pipelines 정렬 기준 지정
  - 값: `id`, `status`, `ref`, `updated_at`, `user_id` (default: `id`)
  - ex) order_by=ref
- **sort**
  - `asc` 또는 `desc` 순으로 pipelines 정렬(default: `desc`)
  - ex) sort=desc

### 기본 형식
```bash
curl --header "PRIVATE-TOKEN: <Personal access token>" "https://<GitLab domain>/api/v4/projects/<Project ID>/pipelines"
```

### 사용 예시
2022-10-10부터 2022-10-29사이에 성공적으로 업데이트된 main 브랜치 pipeline을 id 기준으로 내림차순 정렬해서 조회

```bash
curl -s --header "PRIVATE-TOKEN: <Personal access token>" "https://<GitLab domain>/api/v4/projects/<Project ID>/pipelines?status=success&ref=main&updated_after=2022-10-10&updated_before=2022-10-29&order_by=id&sort=desc"
```

<hr>

## 참고
- **Pipelines API** - https://docs.gitlab.com/ee/api/pipelines.html
