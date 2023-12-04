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

1. GitLab용 database user 생성(d option은 db name).
   ```
   sudo psql -U postgres -d template1 -c "CREATE USER gitlab WITH LOGIN PASSWORD '<GITLAB_SQL_PASSWORD>' CREATEDB;"
   ```

2. 확장 module인 pg_trgm, btree_gist, plpgsql 생성. 
   ```
   sudo psql -U postgres -d template1 -c "CREATE EXTENSION IF NOT EXISTS pg_trgm;"
   sudo psql -U postgres -d template1 -c "CREATE EXTENSION IF NOT EXISTS btree_gist;"
   sudo psql -U postgres -d template1 -c "CREATE EXTENSION IF NOT EXISTS plpgsql;"
   ```

3. GitLab production database를 생성하고 새 user에게 database에 대한 모든 권한을 부여
   ```
   sudo psql -U postgres -d template1 -c "CREATE DATABASE gitlabhq_production OWNER gitlab;"
   ```

4. 새 user로 새 database에 연결
   ```
   sudo psql -U gitlab -H -d gitlabhq_production
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
Gitaly Cluster의 routing 및 transaction 관리자인 Praefect는 Gitaly Cluster 상태에 data를 저장하기 위해 자체 database server가 필요.

> [!IMPORTANT]  
> [PostgreSQL 구성](#postgresql-구성) 후 진행

1. 관리 access 권한으로 Praefect PostgreSQL에 연결
    ```
    sudo psql -U postgres -d template1 -h <PRAEFECT_POSTGRESQL_HOST>
    ```

2. Praefect에서 사용할 새 user인 `praefect` 생성.
    ```sql
    CREATE ROLE praefect WITH LOGIN PASSWORD '<PRAEFECT_SQL_PASSWORD>';
    ```

3. `praefect`를 소유자로 새 database인 `praefect_production` 생성.
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

   praefect['enable'] = true

   praefect['auto_migrate'] = false
   gitlab_rails['auto_migrate'] = false

   praefect['configuration'] = {
      listen_addr: '0.0.0.0:2305',
      auth: {
         token: '<PRAEFECT_EXTERNAL_TOKEN>',
      },
      database: {
         host: '<PRAEFECT_POSTGRESQL_HOST>',
         port: 5432,
         session_pooled: {
            host: '<PRAEFECT_POSTGRESQL_HOST>',
            port: 5432,
            dbname: 'praefect_production',
            user: 'praefect',
            password: '<PRAEFECT_SQL_PASSWORD>',
         },
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

3. 구성한 첫 번째 Linux package node(ex. Primary Redis/Sentinel instance)의 `/etc/gitlab/gitlab-secrets.json`을 복사하고 이 server에 교체.

4. `/etc/gitlab/gitlab.rb`를 수정해서 Praefect 데이터베이스 자동 마이그레이션을 다시 활성화.  
   (Praefect node가 여러 개인 경우, deploy node에서만 진행)
   ```ruby
   praefect['auto_migrate'] = true
   ```

   변경 사항을 `/etc/gitlab/gitlab.rb`에 저장하고 Praefect 재구성.
   ```
   gitlab-ctl reconfigure
   ```

5. Praefect가 PostgreSQL에 연결할 수 있는지 확인.
   ```
   sudo -u git /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml sql-ping
   ```

<br>

### Gitaly 구성
GitLab이 설치된 3개 이상의 server가 Gitaly nodes로 구성됨.  
이들은 전용 nodes여야 하며, 이 nodes에서 다른 services를 실행하지 말 것.

1. GitLab Linux package download 및 install.

2. `/etc/gitlab/gitlab.rb` 수정.
   ```ruby
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

   gitlab_rails['auto_migrate'] = false
   gitlab_rails['internal_api_url'] = 'https://<GITLAB_DOMAIN>'

   gitaly['enable'] = true
   gitaly['configuration'] = {
      listen_addr: '0.0.0.0:8075',
      auth: {
         token: '<PRAEFECT_INTERNAL_TOKEN>',
      },
      storage: [
         {
            name: 'gitaly-1',                          # Gitaly server 2에는 값에 'gitaly-2'를, Gitaly server 3에는 값에 'gitaly-3'을 입력.
            path: '/var/opt/gitlab/git-data',
         },
      ],
   }
   ```

3. 구성한 첫 번째 Linux package node(ex. Primary Redis/Sentinel instance)의 `/etc/gitlab/gitlab-secrets.json`을 복사하고 이 server에 교체.

4. Gitaly 재구성.
   ```
   gitlab-ctl reconfigure
   ```

5. 각 Praefect node에 SSH로 연결하고 Praefect connection checker를 실행.  
   Praefect가 Praefect 구성의 모든 Gitaly servers에 연결할 수 있는지 확인.
  
   ```
   sudo /opt/gitlab/embedded/bin/praefect -config /var/opt/gitlab/praefect/config.toml dial-nodes
   ```

<br>

## GitLab application(Sidekiq + GitLab Rails) 구성
`git_data_dirs`에 추가된 storage 이름은 Praffect nodes의 `Praffect['configuration'][:virtual_storage]`에 있는 storage 이름(ex: `default`)과 일치해야 함.

1. GitLab Linux package download 및 install.

2. `/etc/gitlab/gitlab.rb` 수정.
   ```ruby
   prometheus['enable'] = false
   alertmanager['enable'] = false
   grafana['enable'] = false
   gitlab_exporter['enable'] = false
   gitlab_kas['enable'] = false

   external_url 'https://<GITLAB_DOMAIN>'

   letsencrypt['enable'] = false

   nginx['enable'] = true
   nginx['listen_port'] = 80
   nginx['listen_https'] = false
   nginx['redirect_http_to_https'] = false

   gitaly['enable'] = false
   git_data_dirs({
      "default" => {
         "gitaly_address" => "tcp://<INTERNAL_LOAD_BALANCER_HOST>:2305", # internal load balancer IP
         "gitaly_token" => '<PRAEFECT_EXTERNAL_TOKEN>'
      }
   })

   postgresql['enable'] = false
   gitlab_rails['db_adapter'] = 'postgresql'
   gitlab_rails['db_encoding'] = 'utf8'
   gitlab_rails['db_database'] = 'gitlabhq_production'
   gitlab_rails['db_username'] = 'gitlab'
   gitlab_rails['db_host'] = '<POSTGRESQL_HOST>'
   gitlab_rails['db_port'] = 5432
   gitlab_rails['db_password'] = '<GITLAB_SQL_PASSWORD>'

   gitlab_rails['auto_migrate'] = false

   redis['enable'] = false
   redis['master_name'] = 'gitlab-redis'
   redis['master_password'] = '<REDIS_PASSWORD>'

   gitlab_rails['redis_sentinels'] = [
      {'host' => '<REDIS_SENTINEL_1_HOST>', 'port' => 26379},
      {'host' => '<REDIS_SENTINEL_2_HOST>', 'port' => 26379},
      {'host' => '<REDIS_SENTINEL_3_HOST>', 'port' => 26379},
   ]

   sidekiq['enable'] = true
   sidekiq['listen_address'] = "0.0.0.0"
   sidekiq['queue_groups'] = ['*'] * 2
   sidekiq['max_concurrency'] = 20
   ```

3. 구성한 첫 번째 Linux package node(ex. Primary Redis/Sentinel instance)의 `/etc/gitlab/gitlab-secrets.json`을 복사하고 이 server에 교체.

4. 구성한 첫 번째 Omnibus node(ex. Primary Redis/Sentinel instance)에서 SSH host keys(`/etc/ssh/ssh_host_*_key*` 형식의 이름)를 복사하고 이 server에 교체.  
   이렇게 하면 사용자가 load balancing된 Rails nodes에 도달할 때 host 불일치 오류가 발생하지 않음.

5. 모든 migrations가 활성화 되었는지 확인:
   ```
   gitlab-rake gitlab:db:configure
   ```

6. Database에서 authorized SSH keys를 빠르게 조회하도록 구성.  
   OpenSSH는 선형 검색을 통해 user에게 권한을 부여하는 key를 검색하므로 users 수가 증가함에 따라 일반 SSH 작업이 느려짐.
   User에게 GitLab access 권한이 없는 경우와 같은 최악의 경우 OpenSSH는 전체 file을 scan하여 key를 검색.
   여기에는 상당한 시간과 disk I/O가 소요될 수 있으며 이로 인해 users가 repository에 push하거나 pull하려는 시도가 지연됨.
   게다가, users가 keys를 자주 추가하거나 제거하면 운영 체제가 `authorized_keys` file을 cache하지 못해 disk에 반복적으로 access하게 될 가능성 존재.

   GitLab Shell은 GitLab database에서 빠른 색인 조회를 통해 SSH users에게 권한을 부여하는 방법을 제공하여 이 문제를 해결.  
   GitLab Shell은 SSH key의 fingerprint를 사용하여 user가 GitLab에 access할 수 있는 권한이 있는지 확인.

   1. `sshd_config` file에 다음을 추가. 이 file은 일반적으로 `/etc/ssh/sshd_config`에 있지만 Omnibus Docker를 사용하는 경우에는 `/assets/sshd_config`에 존재:
      ```
      Match User git    # Apply the AuthorizedKeysCommands to the git user only
      AuthorizedKeysCommand /opt/gitlab/embedded/service/gitlab-shell/bin/gitlab-shell-authorized-keys-check git %u %k
      AuthorizedKeysCommandUser git
      Match all    # End match, settings apply to all users again
      ```
   2. OpenSSH reload:
      ```
      # Debian or Ubuntu installations
      sudo service ssh reload

      # CentOS installations
      sudo service sshd reload
      ```
   3. `authorized_keys` file에서 user's key를 주석 처리하여 SSH가 작동하는지 확인하고 local machine에서 repository를 pull하거나 다음을 실행:
      ```
      ssh -T git@<GITLAB_DOMAIN>
      ```

      성공적인 pull 또는 환영 message는 file에 존재하지 않는 key를 GitLab이 database에서 찾을 수 있다는 의미.

7. GitLab 재구성.
   ```
   gitlab-ctl reconfigure
   ```

8. 증분 logging 활성화.

   GitLab Runner는 통합 객체 storage를 사용하는 경우에도, Omnibus GitLab이 기본적으로 disk의 `/var/opt/gitlab/gitlab-ci/builds`에 임시로 cache하는 chunks로 job logs를 반환.  
   기본 구성을 사용하면 이 directory는 모든 GitLab Rails 및 Sidekiq nodes에서 NFS를 통해 공유되어야 함.  
   NFS를 통한 job logs 공유는 지원되지만 증분 logging(NFS node가 배포되지 않은 경우 필요)을 활성화하여 NFS 사용을 피하는 것을 권장.  
   증분 logging은 job logs의 임시 caching을 위해 disk 공간 대신 ​​Redis를 사용.

   job이 완료된 후 background job이 job log를 보관.  
   Log는 기본적으로 artifacts directory로 이동되거나 구성된 경우 객체 storage로 이동됨.  
   두 개 이상의 servers에서 실행되는 Rails 및 Sidekiq이 포함된 확장 architecture에서는 file system의 두 위치를 NFS를 사용하여 공유해야 하는데 이는 권장되지 않음.

   ※ 객체 storage 활성화 후 진행.

   1. Rails console open:

      ```
      gitlab-rails console
      ```
   2. 기능 플래그를 활성화:

      ```ruby
      Feature.enable(:ci_enable_live_trace)
      ```

      실행 중인 job의 logs는 계속해서 disk에 기록되지만 새 jobs는 증분 logging을 사용.

   3. `authorized_keys` file 쓰기 권한 비활성화:

      ※ GitLab 구성이 완료되어 UI 접속이 된 후에 진행.

      > [!WARNING]  
      > SSH가 완벽하게 작동하는 것으로 확인될 때까지 쓰기 비활성화 금지.
      > 그렇지 않으면 file이 빨리 out-of-date됨.
      
      1. 상당 표시줄에서 **Main menu > Admin** 선택.
      2. 왼쪽 sidebar에서 **Settings > Network** 선택.
      3. **Performance optimization** 확장.
      4. **Use authorized_keys file to authenticate SSH keys** checkbox 선택 취소.
      5. **Save changes** 선택.

      다시 한 번 UI에서 user의 SSH key를 제거하고 새 key를 추가한 후 repository pull을 시도하여 SSH가 작동하는지 확인.
      그런 다음 최상의 성능을 위해 `authorized_keys` file을 백업하고 삭제 가능.
      현재 users의 kyes는 이미 database에 있으므로 migration하거나 users의 keys 재추가 불필요.

10. Node가 Gitaly에 연결할 수 있는지 확인:

   ```
   gitlab-rake gitlab:gitaly:check
   ```

11. GitLab services가 실행 중인지 확인:

    ```
    gitlab-ctl status
    ```


13. 새 project를 생성하여 모든 것이 작동하는지 확인.

    조회한 repository에 content가 있도록 "Initialize repository with a README" 상자 선택.  
    project가 생성되고 README file이 보이면 제대로 된 것.

14. Repository가 정상적으로 servers에 저장되었는지 확인.

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
- **Database에서 authorized SSH keys를 빠르게 조회** - https://docs.gitlab.com/ee/administration/operations/fast_ssh_key_lookup.html
- **Repository metadata 보기** - https://docs.gitlab.com/ee/administration/gitaly/troubleshooting.html#view-repository-metadata
