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
(★★는 하나로 합쳐서 구성)

- **GitLab Rails** ★★  
  GitLab의 핵심 요소.  
  여러 Components와 상호작용하는 역할 수행.
- **Sidekiq** ★★  
  Background job processor이며 Redis를 job 대기열의 data 저장소로 사용.
- **Redis/Sentinel** ★  
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
  - 10.6.0.31
- **GITLAB_APPLICATION_1_HOST**
  - 10.6.0.41
- **GITLAB_APPLICATION_2_HOST**
  - 10.6.0.42
- **GITALY_1_HOST**
  - 10.6.0.51
- **GITALY_2_HOST**
  - 10.6.0.52
- **GITALY_3_HOST**
  - 10.6.0.93
- **REDIS_SENTINEL_1_HOST**
  - 10.6.0.61
- **REDIS_SENTINEL_2_HOST**
  - 10.6.0.62
- **REDIS_SENTINEL_3_HOST**
  - 10.6.0.63
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
- **REDIS_PASSWORD**
  - P@ssw0rd1!
- **GITLAB_SQL_PASSWORD**
  - P@ssw0rd1!
- **PRAEFECT_SQL_PASSWORD**
  - P@ssw0rd1!
- **PRAEFECT_EXTERNAL_TOKEN**
  - 624A79DED9D1FAD49E574A722DE1FE421312321BEACB4DF18677D11DFE5C44A1
- **PRAEFECT_INTERNAL_TOKEN**
  - D7A21C324B08464ECF0D24A40375802686AF4D237E3714051AF2035B5214462D

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

## Internal Load Balancer 구성
| LB Port | Backend port | Protocol |
|---|---|---|
| 2305 | 2305 | TCP |

### HAProxy 설정
> [!IMPORTANT]  
> Nginx proxy_pass에 http://로 할 경우 TCP 통신이 불가능하므로, HAProxy로 진행.

HAProxy 설정 file 작성.
```
# Docker로 haproxy 설치 시 경로. Source로 haproxy 설치 시 경로는 /etc/haproxy
cd /usr/local/etc/haproxy/
vi haproxy.cfg
```

```haproxy
global
    log /dev/log local0
    log localhost local1 notice
    log stdout format raw local0

defaults
    log global
    default-server inter 10s fall 3 rise 2
    balance leastconn

frontend internal-praefect-tcp-in
    bind *:2305
    mode tcp
    option tcplog
    option clitcpka

    default_backend praefect

backend praefect
    mode tcp
    option tcp-check
    option srvtcpka

    server praefect1 10.6.0.131:2305 check
    server praefect2 10.6.0.132:2305 check
    server praefect3 10.6.0.133:2305 check
```

<br>

## Redis/Sentinel 구성
확장 가능한 환경에서 Redis를 사용하면, Redis Sentinel service와 함께 **Primary x Replica** topology를 사용하여 장애 조치 절차를 감시하고 자동으로 시작하는 것이 가능.

> [!IMPORTANT]  
> Redis clusters 및 Redis Sentinel은 각각 3개 이상의 홀수 nodes에 배포되어야 하는데, 이는 Redis Sentinel이 quorum의 일부로 투표를 할 수 있도록 하기 위한 것.

### Linux package를 사용하는 독립형 Redis 구성
요구 사항:  
1. 모든 Redis nodes는 서로 통신할 수 있어야 하며 Redis(`6379`) 및 Sentinel(`26379`) ports(기본 ports를 변경하지 않는 한)를 통해 들어오는 연결을 수락할 수 있어야 함.
2. GitLab application을 hosting하는 server는 Redis nodes에 access할 수 있어야 함.
3. 방화벽을 사용하여 외부 networks(internet)의 access로부터 nodes 보호 필요.

Primary 및 replica Redis nodes 모두 `redis['password']`에 정의된 동일한 비밀번호 필요.  
장애 조치 중 언제든지 Sentinels는 node를 재구성하고 해당 상태를 primary에서 replica로(또는 그 반대로) 변경 가능.

#### Primary Redis/Sentinel instance 구성
1. GitLab Linux package download 및 install.

2. `/etc/gitlab/gitlab.rb` 수정.
   ```ruby
   roles(['redis_master_role', 'redis_sentinel_role'])

   redis['bind'] = '<REDIS_SENTINEL_1_HOST>'
   redis['port'] = 6379
   redis['password'] = '<REDIS_PASSWORD>'

   redis['master_name'] = 'gitlab-redis'
   redis['master_password'] = '<REDIS_PASSWORD>'
   redis['master_ip'] = '<REDIS_SENTINEL_1_HOST>'
   redis['master_port'] = 6379

   sentinel['bind'] = '<REDIS_SENTINEL_1_HOST>'
   sentinel['port'] = 26379
   sentinel['quorum'] = 2

   gitlab_rails['auto_migrate'] = false
   ```

3. Gitaly 재구성.
   ```
   gitlab-ctl reconfigure
   ```

#### Replica Redis/Sentinel instances 구성
1. GitLab Linux package download 및 install.

2. `/etc/gitlab/gitlab.rb` 수정.
   ```ruby
   roles(['redis_replica_role', 'redis_sentinel_role'])

   redis['bind'] = '<REDIS_SENTINEL_2_HOST>'              # 3번 node에선 <REDIS_SENTINEL_3_HOST>
   redis['port'] = 6379
   redis['password'] = '<REDIS_PASSWORD>'

   redis['master_name'] = 'gitlab-redis'
   redis['master_password'] = '<REDIS_PASSWORD>'
   redis['master_ip'] = '<REDIS_SENTINEL_1_HOST>'
   redis['master_port'] = 6379

   sentinel['bind'] = '<REDIS_SENTINEL_2_HOST>'           # 3번 node에선 <REDIS_SENTINEL_3_HOST>
   sentinel['port'] = 26379
   sentinel['quorum'] = 2

   gitlab_rails['auto_migrate'] = false
   ```

3. 구성한 첫 번째 Linux package node(ex. Primary Redis/Sentinel instance)의 `/etc/gitlab/gitlab-secrets.json`을 복사하고 이 server에 교체.

4. Gitaly 재구성.
    ```
    gitlab-ctl reconfigure
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

<br>

## Gitaly Cluster 구성
Gitaly Cluster는 Git repositories 저장을 위해 GitLab에서 제공하고 권장하는 내결함성 solution.  
이 구성에서 모든 Git repository는 cluster의 모든 Gitaly node에 저장되며, 한 node는 primary로 지정되는데 primary node가 다운되면 자동으로 장애 조치가 발생.

### Praefect PostgreSQL 구성
1. 관리 access 권한으로 PostgreSQL server에 연결
    ```
    sudo psql -U postgres -d template1 -h '<POSTGRESQL_HOST>'
    ```

2. Praefect에서 사용할 새 user인 `praefect` 생성.
    ```sql
    CREATE ROLE praefect WITH LOGIN PASSWORD '<PRAEFECT_SQL_PASSWORD>';
    ```

3. `praefect`를 소유자로 새 database인 praefect_production 생성.
    ```sql
    CREATE DATABASE praefect_production WITH OWNER praefect ENCODING UTF8;
    ```

<br>

### Praefect 구성
Praefect는 Gitaly Cluster의 router이자 transaction 관리자이며, Gitaly에 대한 모든 연결은 praefect를 통과.

> [!IMPORTANT]  
> Praefect는 3개 이상의 홀수 nodes에 배포되어야 하는데, 이는 nodes가 quorum의 일부로 투표를 할 수 있도록 하기 위한 것.

Praefect는 cluster 전반의 통신을 보호하기 위해 몇 가지 secret tokens가 필요:
- `PRAEFECT_EXTERNAL_TOKEN`: Gitaly cluster에서 hosting되는 repositories에 사용되며, 이 token을 가지고 있는 Gitaly clients에서만 access 가능.
- `PRAEFECT_INTERNAL_TOKEN`: Gitaly cluster 내부의 복제 traffic에 사용되는데, 이는 Gitaly clients가 Praefect cluster의 내부 nodes에 직접 access할 수 없어야 한다는 점에서 `PRAEFECT_EXTERNAL_TOKEN`과 다름. 이는 data 손실로 이어질 가능성 존재.
- `PRAEFECT_SQL_PASSWORD`: 이전 섹션에서 정의한 Praefect PostgreSQL 비밀번호도 이 설정의 일부로 필요.

Praefect node가 여러 개인 경우 하나의 node를 deploy node로 지정.

> [!WARNING]  
> Praefect는 전용 node에서만 실행 필수.  
> Application server 또는 Gitaly node에서 Praefect를 실행하지 말 것.

<br>

1. GitLab Linux package download 및 install.

2. `/etc/gitlab/gitlab.rb` 수정.
    ```ruby
    # Avoid running unnecessary services on the Praefect server
    gitaly['enable'] = false
    postgresql['enable'] = false
    redis['enable'] = false
    nginx['enable'] = false
    puma['enable'] = false
    sidekiq['enable'] = false
    gitlab_workhorse['enable'] = false
    prometheus['enable'] = false
    alertmanager['enable'] = false
    grafana['enable'] = false
    gitlab_exporter['enable'] = false
    gitlab_kas['enable'] = false
    
    # Enable only the Praefect service
    praefect['enable'] = true
    
    # Prevent database migrations from running on upgrade automatically
    praefect['auto_migrate'] = false
    gitlab_rails['auto_migrate'] = false

    praefect['configuration'] = {
       listen_addr: '0.0.0.0:2305',
       auth: {
          token: '<PRAEFECT_EXTERNAL_TOKEN>',
       },
       database: {
          host: '<PRAEFECT_POSTGRESQL_HOST'>,
          port: 5432,
          dbname: 'praefect_production',
          user: 'praefect'
          password: '<PRAEFECT_SQL_PASSWORD>',
       },
       virtual_storage: [
          {
             name: 'default',
             node: [
                {
                   storage: 'gitaly-1',
                   address: 'tcp://<GITALY_1_HOST>:8075',
                   token: '<PRAEFECT_INTERNAL_TOKEN>'
                },
                {
                   storage: 'gitaly-2',
                   address: 'tcp://<GITALY_2_HOST>:8075',
                   token: '<PRAEFECT_INTERNAL_TOKEN>'
                },
                {
                   storage: 'gitaly-3',
                   address: 'tcp://<GITALY_3_HOST>:8075',
                   token: '<PRAEFECT_INTERNAL_TOKEN>'
                },
             ],
          },
       ],
    }
    ```

3. 구성한 첫 번째 Linux package node에서 `/etc/gitlab/gitlab-secrets.json`을 복사하고 이 server에 교체.
    
    첫 번째 Linux package node인 경우 이 단계 skip 가능.

4. `/etc/gitlab/gitlab.rb`를 수정해서 Praefect 데이터베이스 자동 마이그레이션을 다시 활성화.  
    (Praefect node가 여러 개인 경우, deploy node에서만 진행)
    ```ruby
    praefect['auto_migrate'] = true
    ```

    변경 사항을 `/etc/gitlab/gitlab.rb`에 저장하고 Praefect 재구성.
    ```
    gitlab-ctl reconfigure
    ```

5. Praefect 재시작.
    ```
    gitlab-ctl restart praefect
    ```

6. Praefect가 PostgreSQL에 연결할 수 있는지 확인.
    ```
    sudo -u git /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml sql-ping
    ```
    
    ※ sudo 명령어 실행이 불가능할 경우 다음과 같이 실행.
    ```
    su git
    /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml sql-ping
    ```

<br>

### Gitaly 구성
GitLab이 설치된 3개 이상의 server가 Gitaly nodes로 구성됨.  
이들은 전용 nodes여야 하며, 이 nodes에서 다른 services를 실행하지 말 것.

1. GitLab Linux package download 및 install.

2. `/etc/gitlab/gitlab.rb` 수정.
    ```ruby
    # Disable all other services on the Gitaly node
    postgresql['enable'] = false
    redis['enable'] = false
    nginx['enable'] = false
    grafana['enable'] = false
    puma['enable'] = false
    sidekiq['enable'] = false
    gitlab_workhorse['enable'] = false
    prometheus_monitoring['enable'] = false
    gitlab_kas['enable'] = false
    
    # Enable only the Gitaly service
    gitaly['enable'] = true
    
    # Disable database migrations to prevent database connections during 'gitlab-ctl reconfigure'
    gitlab_rails['auto_migrate'] = false
    
    # Configure the gitlab-shell API callback URL. Without this, `git push` will fail.
    # This can be your front door GitLab URL or an internal load balancer.
    gitlab_rails['internal_api_url'] = 'https://<GITLAB_DOMAIN>'
    
    gitaly['configuration'] = {
       listen_addr: '0.0.0.0:8075',
       auth: {
          token: '<PRAEFECT_INTERNAL_TOKEN>',
       },
       storage: [
          {
             name: 'gitaly-1',
             path: '/var/opt/gitlab/git-data',
          },
          {
             name: 'gitaly-2',
             path: '/var/opt/gitlab/git-data',
          },
          {
             name: 'gitaly-3',
             path: '/var/opt/gitlab/git-data',
          },
       ],
    }
    ```

3. 구성한 첫 번째 Linux package node에서 `/etc/gitlab/gitlab-secrets.json`을 복사하고 이 server에 교체.
    
    첫 번째 Linux package node인 경우 이 단계 skip 가능.

4. Gitaly 재구성.
    ```
    gitlab-ctl reconfigure
    ```

5. Gitaly 재시작.
    ```
    gitlab-ctl restart gitaly
    ```

6. 각 Praefect node에 SSH로 연결하고 Praefect connection checker를 실행.  
  Praefect가 Praefect 구성의 모든 Gitaly servers에 연결할 수 있는지 확인.
  
    ```
    sudo /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml dial-nodes
    ```

<br>

## GitLab application 구성
`git_data_dirs`에 추가된 storage 이름은 Praffect nodes의 `Praffect['configuration'][:virtual_storage]`에 있는 storage 이름(ex: `default`)과 일치해야 함.

1. GitLab Linux package download 및 install.

2. `/etc/gitlab/gitlab.rb` 수정.
    ```ruby
    external_url 'https://<GITLAB_DOMAIN>'
    
    letsencrypt['enable'] = false
    
    nginx['listen_port'] = 80
    nginx['listen_https'] = false
    nginx['redirect_http_to_https'] = true
    
    postgresql['enable'] = false
    
    gitlab_rails['db_adapter'] = 'postgresql'
    gitlab_rails['db_encoding'] = 'unicode'
    gitlab_rails['db_database'] = 'gitlabhq_production'
    gitlab_rails['db_username'] = 'git'
    gitlab_rails['db_password'] = '<GITLAB_SQL_PASSWORD>'
    gitlab_rails['db_host'] = '<POSTGRESQL_HOST>'
    gitlab_rails['db_port'] = 5432
    
    gitaly['enable'] = false
    
    git_data_dirs({
      "default" => {
        "gitaly_address" => "tcp://<INTERNAL_LOAD_BALANCER_HOST>:2305",
        "gitaly_token" => '<PRAEFECT_EXTERNAL_TOKEN>'
      }
    })
    ```

3. 구성한 첫 번째 Linux package node에서 `/etc/gitlab/gitlab-secrets.json`을 복사하고 이 server에 교체.
    
    첫 번째 Linux package node인 경우 이 단계 skip 가능.

4. GitLab 재구성.
    ```
    gitlab-ctl reconfigure
    ```

5. 각 Gitaly node에서 Git Hooks가 GitLab에 도달할 수 있는지 확인. 각 Gitaly node에서 실행.
    ```
    sudo /opt/gitlab/embedded/bin/gitaly check /var/opt/gitlab/gitaly/config.toml
    ```

6. GitLab이 Praefect에 연결할 수 있는지 확인.
    ```
    gitlab-rake gitlab:gitaly:check
    ```

7. Praefect storage가 새 repositories를 저장하도록 구성되었는지 확인.
    1. 왼쪽 side bar에서 맨 위에 있는 갈매기 모양(v) 확장.
    2. **Admin Area** 선택.
    3. 왼쪽 side bar에서 **Settings > Repository** 선택.
    4. **Repository storage** section 확장.
    5. `default` storage가 모든 새 repositories를 저장하기 위해 가중치가 100인 것을 확인.

8. 새 project를 생성하여 모든 것이 작동하는지 확인.
    
    조회한 repository에 content가 있도록 "Initialize repository with a README" 상자 선택.  
    project가 생성되고 README file이 보이면 제대로 된 것.

9. Repository가 정상적으로 servers에 저장되었는지 확인.
    
    Praefects에서 repository metadata 확인.
    ```
    sudo /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml metadata -repository-id <repository-id>
    ```

    `Replica Path`는 Gitaly node disk에 repository의 복제본이 저장되는 위치.  
    Gitaly cluster 구성이므로 @cluster/~로 확인 가능(Gitaly servers에만 존재).

<br>

## ※ 통신 확인
```
# telnet
telnet <DOMAIN or IP> <PORT>
 
# telnet을 사용하지 못할 경우 진행.
curl -v telnet://<DOMAIN or IP>:<PORT>
 
# telnet을 사용하지 못할 경우 진행. 두 번째 명령까지 성공 시 0 출력.
echo > /dev/tcp/<DOMAIN or IP>/<PORT>
echo $?
```

<hr>

## 참고
- **GitLab 참조 architecture: 최대 3,000명의 사용자** - https://docs.gitlab.com/ee/administration/reference_architectures/3k_users.html
- **외부 PostgreSQL 설정** - https://docs.gitlab.com/ee/administration/postgresql/external.html
- **Database 설정** - https://docs.gitlab.com/ee/install/installation.html#7-database
- **Gitaly Cluster 구성** - https://docs.gitlab.com/ee/administration/gitaly/praefect.html
- **Repository metadata 보기** - https://docs.gitlab.com/ee/administration/gitaly/troubleshooting.html#view-repository-metadata
