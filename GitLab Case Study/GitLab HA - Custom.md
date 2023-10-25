# GitLab HA - Custom

<br>

대규모 권장 배포를 제공하기 위해 설계하고 test한 참조 architecture를 기반으로 한 고가용성을 보장하는 GitLab 구성 방식.

구성 요소를 늘려야 하므로 환경 요구 사항이 상당히 크며, 이로 인해 실제 비용과 유지 관리 비용이 추가로 발생.  
일반적으로 사용자가 3,000명 이상이거나 GitLab이 down되면 workflow에 심각한 영향을 미칠 수 있는 경우에 사용.  
GitLab users 수 및 workflow에 따라 권장 참조 architecture를 적절하게 조정 필요.

GitLab HA 구성을 위해서 **GitLab package (Omnibus)** 를 이용하는 방식과 **Cloud native hybrid**를 이용하는 방식 중 선택 가능.

<br>

## Architecture
**※ 최대 3,000명 users architecture**  
![image](https://github.com/bigmtn1113/GitLab-Note/assets/46125158/380de95f-251f-481d-91c9-6d37a85210d4)

### Components
상황에 맞춰서 custom하게 components 분리 가능.  
본 page에선 ★ 표시되어 있는 것만 분리 구성.  
(★★는 단일 GitLab server에서 default로 운영)

- **GitLab Rails** ★★  
  GitLab의 핵심 요소.  
  여러 Components와 상호작용하는 역할 수행.
- **Sidekiq** ★★  
  Background job processor이며 Redis를 job 대기열의 data 저장소로 사용.
- **Redis** ★★  
  Sidekiq을 사용하여 작업 처리 대기열로 사용되며, 모든 사용자 session과 background job 대기열을 저장.
- **External Load Balancer** ★  
  GitLab URL 접근 시 GitLab application servers로 traffic을 routing.
- **Internal Load Balancer** ★  
  PgBouncer 및 Praefect(Gitaly Cluster)에 대한 연결과 같이 GitLab 환경에 필요한 내부 연결의 균형을 유지하는 데 사용.
- **Praefect** ★  
  모든 traffic을 Gitaly storage nodes로 routing하여 Gitaly cluster를 제공.  
  요청을 검사하고 이를 올바른 Gitaly backend로 routing하려고 시도하면 Gitaly가 작동 중인지 확인하고 data 사본이 최신 상태인지 확인하는 등의 작업 수행.
- **Gitaly** ★  
  GitLab의 Git access 속도가 느려지는 문제를 해결하기 위해 구축한 Git repositories에 대한 높은 수준의 RPC access를 제공하는 service.  
  GitLab에서 Git data를 읽고 쓰는 용도로 사용.
- **PostgreSQL** ★  
  GitLab용 Database.
- **Praefect PostgreSQL** ★  
  Praefect가 Gitaly Cluster 상태에 data를 저장하기 위해 사용.  
  Repositories가 위치한 곳 및 일부 대기중인 작업들에 대한 metadata 포함.  
  ※ 요구 사항이 상대적으로 낮음.
- Object storage  
  다양한 유형의 data를 보관하기 위해 사용.
- Prometheus  
  GitLab을 monitoring하기 위한 service.
- Grafana  
  Prometheus 성능 지표를 data source로 가져오고 지표를 시각화에 도움이 되는 graphs 및 dashboards로 rendering하는 service.
- Consul  
  Service 검색 및 구성을 위한 도구.
- PGBouncer  
  Database 연결 사용을 최적화할 목적으로 connection pooling에 PgBouncer를 사용.

<br>

## 구성 환경
### GitLab 및 Database version
- **GitLab**
  - 15.11.11-ee
- **Database(PostgreSQL)**
  - 13.11

<br>

### 변수 설정
- **EXTERNAL_LOAD_BALANCER**
  - 10.6.0.10
- **INTERNAL_LOAD_BALANCER**
  - 10.6.0.20
- **POSTGRESQL**
  - 10.6.0.31
- **GITLAB_APPLICATION**
  - 10.6.0.41
- **GITALY_1**
  - 10.6.0.51
- **GITALY_2**
  - 10.6.0.52
- **GITALY_3**
  - 10.6.0.93
- **PRAEFECT_1**
  - 10.6.0.131
- **PRAEFECT_2**
  - 10.6.0.132
- **PRAEFECT_3**
  - 10.6.0.133
- **PRAEFECT_POSTGRESQL**
  - 10.6.0.141
- **GITLAB_URL**
  - https://gitlab.example.com

<br>

<hr>

## 참고
- **GitLab 참조 architecture: 최대 3,000명의 사용자** - https://docs.gitlab.com/ee/administration/reference_architectures/3k_users.html
