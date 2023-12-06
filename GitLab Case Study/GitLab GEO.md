# GitLab GEO

<br>

> [!WARNING]  
> Geo는 출시될 때마다 상당한 변화가 발생.  
> Upgrade가 지원되고 문서화되어 있지만 설치에 적합한 version의 문서를 사용하고 있는지 확인 필요.  
> 본 내용에선 `v15.11.11-ee`로 진행.

단일 GitLab instance에서 멀리 떨어져 있는 teams의 경우 대규모 repositories를 가져오는 데 오랜 시간이 걸릴 가능성 존재.  
Geo는 GitLab instances의 local 읽기 전용 sites를 제공.  
이를 통해 대규모 repositories를 복제하고 가져오는 데 걸리는 시간을 줄여, 개발 속도 향상 가능.

<br>

## 요구사항
- 독립적으로 작동하는 두 개 이상의 GitLab sites.
- Primary site에 GitLab Premium license 이상 적용.
- 동일한 GitLab version을 사용하는 sites.

### 방화벽 정책
Geo의 **primary**와 **secnodary** sites 사이에 열려 있어야 하는 기본 ports가 존재.  
장애 조치를 단순화하려면 양방향으로 ports를 open할 것.

Source site	| Source port	| Destination site | Destination port	| Protocol
:---: | :---: | :---: | :---: | :---:
Primary	| Any	| Secondary	| 80 | TCP (HTTP)
Primary	| Any	| Secondary	| 443	| TCP (HTTPS)
Secondary	| Any	| Primary	| 80 | TCP (HTTP)
Secondary	| Any	| Primary	| 443	| TCP (HTTPS)
Secondary | Any	| Primary	| 5432 | TCP

<hr>

## 참고
- **GitLab GEO** - https://archives.docs.gitlab.com/15.11/ee/administration/geo/
