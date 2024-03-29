# Prometheus 및 Grafana

<br>

## Prometheus
GitLab 및 기타 software 제품을 monitoring하기 위한 유연한 platform을 제공하는 강력한 시계열 monitoring service  
GitLab은 Prometheus와 함께 즉시 사용 가능한 monitoring을 제공하여 GitLab services의 고품질 시계열 monitoring에 쉽게 access 가능

Prometheus 및 다양한 exporter는 Omnibus GitLab package에 bundle로 포함되어 있고 Prometheus services는 기본적으로 활성화(http://localhost:9090)된 상태  
Prometheus와 다양한 exporters는 사용자를 인증하지 않으며 access할 수 있는 모든 사람(일반 users도 url로 접근 가능)이 사용 가능

Prometheus는 주기적으로 data sources에 연결하고 다양한 exporters를 통해 성능 metrics을 수집하여 작동  
Monitoring data를 보고 작업하려면 Prometheus에 직접 연결하거나 Grafana와 같은 dashboard 도구 사용 가능

### GitLab metrics
GitLab은 자체 내부 service metrics를 monitoring하고 `/-/metrics` endpoint에서 사용 가능

![image](https://user-images.githubusercontent.com/46125158/230763466-09160ad7-ebf8-4c3c-825e-28dc9d8ceedb.png)

다른 exporters와 달리 이 endpoint는 사용자 traffic과 동일한 URL 및 port에서 사용할 수 있으므로 인증이 필요  
즉, metrics에 access하려면 client IP 주소를 명시적으로 허용하는 작업(IP whitelisting) 필요

#### IP whitelist
GitLab은 검색 시 health check 정보를 제공하는 일부 monitoring endpoints를 제공

IP whitelisting을 통해 해당 endpoints에 대한 access를 제어하려면 단일 hosts를 추가하거나 IP 범위 사용 가능

`/etc/gitlab/gitlab.rb`  
```ruby
gitlab_rails['monitoring_whitelist'] = ['127.0.0.0/8', '::1/128', '221.148.114.22/32']
```

### Bundeld software metrics
Omnibus GitLab에 bundle로 제공되는 많은 GitLab 종속성은 Prometheus 측정항목을 export하도록 미리 구성된 상태

#### Node exporter
Memory, disk 및 CPU 사용률과 같은 다양한 machine resources 측정 가능

- 기본적으로 비활성화
- `localhost:9100` 사용

#### Web exporter
End-user와 Prometheus traffic을 두 개의 별도 applications로 분할하여 성능과 가용성을 개선할 수 있는 전용 metrics server

- 기본적으로 비활성화
- `localhost:8083/metrics` 사용

※ GitLab metrics와의 차이
- 동일한 기능이나 성능 특성 차이
- 기본 Rails application을 통한 방식이 기본값이며 소규모 GitLab 설치의 경우 권장. `/-/metrics` endpoint 사용
- 전용 metrics server를 통한 방식은 고성능 및 가용성을 추구하는 중대형 GitLab 설치의 경우 권장. 추가 memory 사용 수반

#### Redis exporter
다양한 Redis metrics 측정

- 기본적으로 활성화
- `localhost:9121` 사용

#### PostgreSQL exporter
다양한 PostgreSQL metrics 측정

- 기본적으로 활성화
- `localhost:9187` 사용

#### PgBouncer exporter
다양한 PgBouncer metrics 측정

- 기본적으로 비활성화
- `localhost:9188` 사용

#### Registry exporter
다양한 레지스트리 metrics 측정  
GitLab container registry 활성화 후 사용 가능

- 기본적으로 비활성화
- `localhost:5001/metrics` 사용

#### GitLab exporter
Redis 및 database에서 가져온 다양한 GitLab metrics 측정

- 기본적으로 활성화
- `localhost:9168` 사용

#### ※ 활성화 및 설정
`/etc/gitlab/gitlab.rb`  
```ruby
# Node exporter
node_exporter['enable'] = true

# Web exporter
puma['exporter_enabled'] = true
puma['exporter_address'] = "127.0.0.1"
puma['exporter_port'] = 8083

# Redis exporter
redis_exporter['enable'] = true

# PostgreSQL exporter
postgres_exporter['enable'] = true

# PgBouncer exporter
pgbouncer_exporter['enable'] = true

# Registry exporter
registry['debug_addr'] = "localhost:5001"  # localhost:5001/metrics

# GitLab exporter
gitlab_exporter['enable'] = true
```

<br>

## Grafana
Embedded Prometheus monitoring system에서 성능 metrics를 시각화하는 데 사용할 수 있는 강력한 dashboard 구축 system

### Grafana 활성화
`/etc/gitlab/gitlab.rb`  
```ruby
grafana['enable'] = true
```

활성화되면 https://gitlab.example.com/-/grafana을 통해 Grafana를 사용할 수 있으며 GitLab의 SSO가 자동으로 구성

### 화면
![image](https://user-images.githubusercontent.com/46125158/230772047-0f31cecf-9c56-42d1-96ee-c38a2e2d8afb.png)  
![image](https://user-images.githubusercontent.com/46125158/230772769-cdc4dc47-6d4e-460c-9c65-728907901af8.png)  
![image](https://user-images.githubusercontent.com/46125158/230772698-b33f3766-2975-41bf-920a-8e1786a48580.png)  
![image](https://user-images.githubusercontent.com/46125158/230772324-d27a7618-5ddc-41e8-829d-e41c85794e71.png)

Prometheus는 주기적으로 data sources에 연결하고 다양한 exporters를 통해 성능 metrics을 수집하여 작동  
Grafana를 사용해 monitoring data를 보고 작업 가능

### ※ `login.OAuthLogin(NewTransportWithCode)` error 발생
#### 원인
`/var/log/gitlab/grafana/current`
```
error="Post \"https://gitlab.example.com/oauth/token\": dial tcp 172.18.0.2:443: connect: connection refused"
```

Hostname으로 설정된 domain을 dns resolving할 때 외부 nameserver를 거치지 않고 `/etc/resolv.conf`에 명시된 nameserver(ex. 127.0.0.11)로 먼저 접근. 
따라서 domain에 대해 반환되는 IP는 container IP이며 그 후에 443 port를 통해 service에 연결을 시도  
Reverse-proxy에서 SSL 처리가 끝났기 때문에 container는 443 port에 대한 준비가 되어 있지 않으므로 error 발생

#### 해결책
GitLab 앞에 reverse-proxy를 사용하고 있을 경우 hostname 설정을 하면 해당 error 발생  
`docker-compose.yml`에서 hostname 부분 제거


<hr>

## 참고
- **Prometheus** - https://docs.gitlab.com/ee/administration/monitoring/prometheus/
- **IP whitelist** - https://docs.gitlab.com/ee/administration/monitoring/ip_allowlist.html
- **Grafana** - https://docs.gitlab.com/omnibus/settings/grafana.html
- **Grafana error** - https://gitlab.com/gitlab-org/omnibus-gitlab/-/issues/4917, https://github.com/grafana/grafana/issues/16968
