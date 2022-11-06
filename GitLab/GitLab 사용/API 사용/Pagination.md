# Pagination

<br>

GitLab은 다음과 같은 pagination 방법들을 지원
- **Offset-based pagination**: default 동작 방식
- **Keyset-based pagination**: 점진적으로 출시. 대규모 컬렉션의 경우 성능상의 이유로 Offset 방식보다 이 방식(사용 가능한 경우)을 권장

<br>

## Offset-based pagination
다음과 같은 속성 사용 가능

- **page**
  - 페이지 번호(default: `1`)
  - ex) page=2
- **per_page**
  - 페이지당 나열할 항목 수(default: `20`, max: `100`)
  - ex) per_page=100

### head 옵션 사용
#### 사용 예시
```bash
curl --head --header "PRIVATE-TOKEN: <Personal Access Token>" "https://<GitLab domain>/api/v4/projects"
```

#### Other pagination headers
head 옵션 사용 시, GitLab은 다음과 같은 추가 pagination 헤더 반환

- **x-next-page**
  - 다음 페이지의 인덱스
  - ex) X-Next-Page: 3
- **x-page**
  - 현재 페이지의 인덱스(1부터 시작)
  - ex) X-Page: 2
- **x-per-page**
  - 페이지당 항목 수
  - ex) X-Per-Page: 20
- **x-prev-page**
  - 이전 페이지의 인덱스
  - ex) X-Prev-Page: 1
- **x-total**
  - 총 항목 수
  - ex) X-Total: 244
- **x-total-pages**
  - 총 페이지 수
  - ex) X-Total-Pages: 13

<br>

## ※ Pagination response headers
성능상의 이유로 쿼리가 10,000개 이상의 레코드를 반환하는 경우 GitLab은 다음 헤더를 반환하지 않음

- `x-total`
- `x-total-pages`
- `rel=”last”` `link`

<hr>

## 참고
- **Pagination** - https://docs.gitlab.com/ee/api/index.html#pagination
