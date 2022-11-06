# GitLab API와 script를 이용해 각종 이력을 csv 파일로 추출

<br>

## 시나리오
- GitLab에 있는 모든 **groups list** 추출 - **Groups API** 이용
- GitLab에 있는 모든 **projects list** 추출 - **Projects API** 이용
- GitLab project의 모든 **commits** 추출 - **Commits API** 이용
- GitLab project의 모든 **pipelines** 추출 - **Pipelines API** 이용

<br>

## 전제 조건
**Personal access token**의 scope는 `read_api`

<br>

## GitLab에 있는 모든 groups list 추출
목록의 페이지를 받아온 후 반복문을 통해 페이지별로 값을 조회하고, 그 결과를 .csv 파일에 저장

```bash
#!/usr/bin/env bash

# Update Personal access token, GitLab domain
number_of_pages=$(curl -s --head --header "PRIVATE-TOKEN: <Personal access token>" "https://<GitLab domain>/api/v4/groups" | grep -i x-total-pages | awk '{print $2}' | tr -d '\r\n')

for page in $(seq 1 $number_of_pages); do
    curl -s --header "PRIVATE-TOKEN: <Personal access token>" "https://<GitLab domain>/api/v4/groups?per_page=100&page=$page" >> groups-list.csv
done
```

#### script에서 수정해야 할 부분
- Personal access token
- GitLab domain

<br>

## GitLab에 있는 모든 projects list 추출
목록의 페이지를 받아온 후 반복문을 통해 페이지별로 값을 조회하고, 그 결과를 .csv 파일에 저장

```bash
#!/usr/bin/env bash

# Update Personal access token, GitLab domain
number_of_pages=$(curl -s --head --header "PRIVATE-TOKEN: <Personal access token>" "https://<GitLab domain>/api/v4/projects" | grep -i x-total-pages | awk '{print $2}' | tr -d '\r\n')

for page in $(seq 1 $number_of_pages); do
    curl -s --header "PRIVATE-TOKEN: <Personal access token>" "https://<GitLab domain>/api/v4/projects?per_page=100&page=$page" >> projects-list.csv
done
```

#### script에서 수정해야 할 부분
- Personal access token
- GitLab domain

<br>

## GitLab project의 모든 commits 이력 추출
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

<br>

## GitLab project의 모든 pipelines 이력 추출
반복문을 통해 빈 내용이 조회 될 때까지 결과를 조회하고, 그 결과를 .csv 파일에 저장

```bash
#!/usr/bin/env bash

page_num=1

while true
do
  # Update Personal access token, GitLab domain, Project ID
  pipelines=$(curl -s --header "PRIVATE-TOKEN: <Personal access token>" "https://<GitLab domain>/api/v4/projects/<Project ID>/pipelines?per_page=100&page=${page_num}")

  if [ "${pipelines}" != "[]" ]
  then
    echo $pipelines >> pipelines.csv
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
- **Groups API** - https://docs.gitlab.com/ee/api/groups.html
- **Projects API** - https://docs.gitlab.com/ee/api/projects.html
- **Commits API** - https://docs.gitlab.com/ee/api/commits.html
- **Pipelines API** - https://docs.gitlab.com/ee/api/pipelines.html
