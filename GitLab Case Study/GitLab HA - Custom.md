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

### 변수 확인
- **EXTERNAL_LOAD_BALANCER_HOST**
  - 10.6.0.10
- **INTERNAL_LOAD_BALANCER_HOST**
  - 10.6.0.20
- **POSTGRESQL_HOST**
  - 10.6.0.21
- **GITLAB_APPLICATION_HOST**
  - 10.6.0.41
- **GITALY_1_HOST**
  - 10.6.0.51
- **GITALY_2_HOST**
  - 10.6.0.52
- **GITALY_3_HOST**
  - 10.6.0.93
- **PRAEFECT_1_HOST**
  - 10.6.0.131
- **PRAEFECT_2_HOST**
  - 10.6.0.132
- **PRAEFECT_3_HOST**
  - 10.6.0.133
- **PRAEFECT_POSTGRESQL_HOST**
  - 10.6.0.141
- **GITLAB_DOMAIN**
  - gitlab-example.com
- **GITLAB_SQL_PASSWORD**
  - P@ssw0rd01

<br>

## External Load Balancer 구성
| LB Port | Backend port | Protocol |
|---|---|---|
| 80 | 80 | HTTP |
| 443 | 443 | TCP 또는 HTTP |
| 22 | 22 | TCP |

### Nginx 설정
Nginx 설정 file 작성.
```
cd /etc/nginx/conf.d/
vi <GITLAB_DOMAIN>.conf
```

```nginx
upstream gitlab {
    server <GITLAB_APPLICATION_HOST>:80;
}
 
server {
    listen 443 ssl;
    server_name <GITLAB_DOMAIN>;
	
    ssl_certificate      <fullchain.pem file path>;
    ssl_certificate_key  <privkey.pem file path>;
	
    location / {
        proxy_pass http://gitlab;
    }
}
 
server {
    listen 80;
    server_name <GITLAB_DOMAIN>;
    return 301 https://$host$request_uri;
}
```

<br>

## Internal Load Balancer 구성s
| LB Port | Backend port | Protocol |
|---|---|---|
| 2305 | 2305 | TCP |

### Nginx 설정
Nginx 설정 file 작성.
```
cd /etc/nginx/conf.d/
vi GitLab-Internal-LB.conf
```

```nginx
upstream GitLab-Internal-LB {
    server <PRAEFECT_1_HOST>:2305;
    server <PRAEFECT_2_HOST>:2305;
    server <PRAEFECT_3_HOST>:2305;
}
 
server {
    listen 2305;

    location / {
        proxy_pass http://GitLab-Internal-LB;
    }
}
```

<br>

## PostgreSQL 구성
Cloud provider에서 GitLab을 hosting하는 경우 선택적으로 PostgreSQL용 관리형 service 사용 가능.  
또는 Linux package와 별도로 자체 PostgreSQL instance 또는 cluster를 관리하도록 선택 가능.

1. GitLab용 database user 생성
```
sudo psql -U postgres -d template1 -c "CREATE USER git WITH PASSWORD '<GITLAB_SQL_PASSWORD>' CREATEDB;"
```

2. 확장 module인 pg_trgm, btree_gist, plpgsql 생성. (d option은 db name)
```
sudo psql -U postgres -d template1 -c "CREATE EXTENSION IF NOT EXISTS pg_trgm;"
sudo psql -U postgres -d template1 -c "CREATE EXTENSION IF NOT EXISTS btree_gist;"
sudo psql -U postgres -d template1 -c "CREATE EXTENSION IF NOT EXISTS plpgsql;"
```

3. GitLab production database를 생성하고 database에 대한 모든 권한을 부여
```
sudo psql -U postgres -d template1 -c "CREATE DATABASE gitlabhq_production OWNER git;"
```

4. 새 user로 새 database에 연결
```
sudo psql -U git -H -d gitlabhq_production
```

5. 확장 module인 pg_trgm, btree_gist, plpgsql이 활성화되어 있는지 각각 확인. enabled가 t로 출력
```sql
SELECT true AS enabled
FROM pg_available_extensions
WHERE name = 'pg_trgm'
AND installed_version IS NOT NULL;
 
SELECT true AS enabled
FROM pg_available_extensions
WHERE name = 'btree_gist'
AND installed_version IS NOT NULL;
 
SELECT true AS enabled
FROM pg_available_extensions
WHERE name = 'plpgsql'
AND installed_version IS NOT NULL;
```

6. DB session 종료
```sql
gitlabhq_production> \q
```

7. `/etc/gitlab/gitlab.rb`에서 외부 PostgreSQL service에 대한 적절한 연결 세부 정보로 GitLab application server 구성.
```ruby
postgresql['enable'] = false
 
gitlab_rails['db_adapter'] = 'postgresql'
gitlab_rails['db_encoding'] = 'unicode'
gitlab_rails['db_database'] = 'gitlabhq_production'
gitlab_rails['db_username'] = 'git'
gitlab_rails['db_password'] = '<GITLAB_SQL_PASSWORD>'
gitlab_rails['db_host'] = '<POSTGRESQL_HOST>'
gitlab_rails['db_port'] = 5432
```

8. 변경 사항을 적용하기 위해 GitLab 재구성.
```
sudo gitlab-ctl reconfigure
```

<hr>

## 참고
- **GitLab 참조 architecture: 최대 3,000명의 사용자** - https://docs.gitlab.com/ee/administration/reference_architectures/3k_users.html
- **외부 PostgreSQL 설정** - https://docs.gitlab.com/ee/administration/postgresql/external.html
- **Database 설정** - https://docs.gitlab.com/ee/install/installation.html#7-database
