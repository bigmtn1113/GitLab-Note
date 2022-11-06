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
- **per_page**
  - 페이지 당 나열할 항목 수(default:20, max:100)
  - ex) per_page=100

### 기본 형식
```bash
curl --header "PRIVATE-TOKEN: <Personal access token>" "https://<GitLab domain>/api/v4/projects/<Project ID>/repository/commits"
```

### 사용 예시(script 이용)
반복문을 통해 빈 내용이 조회 될 때까지 결과를 조회하고, 그 결과를 .csv 파일에 저장

```bash
#!/usr/bin/env bash

page_num=1

while true
do
  # Update Personal access token, GitLab domain, Project ID
  commits=$(curl -s --header "PRIVATE-TOKEN: <Personal access token>" "https://<GitLab domain>/api/v4/projects/<Project ID>/repository/commits?all=true&per_page=100&page=${page_num}")

  if [ "${commits}" != "[]" ]
  then
    echo $commits >> commits.csv
  else
    break
  fi

  ((page_num++))
done
```

#### script에서 수정해야 할 부분
- Personal access token
- GitLab domain
- Project ID

<hr>

## 참고
- **Commits API** - https://docs.gitlab.com/ee/api/commits.html
