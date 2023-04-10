# Health Check

<br>

GitLab은 필수 services에 대한 service health 및 reachability을 나타내는 liveness 및 readiness probes를 제공  
이러한 probes는 database 연결, Redis 연결 및 file system에 대한 access 상태를 보고  
이러한 endpoints는 Kubernetes와 같은 schedulers에 제공되어 system이 준비될 때까지 traffic을 유지하거나 필요에 따라 container 재시작 가능

<br>

## IP Whitelist
GitLab은 검색 시 health check 정보를 제공하는 일부 monitoring endpoints를 제공

IP whitelisting을 통해 해당 endpoints에 대한 access를 제어하려면 단일 hosts를 추가하거나 IP 범위 사용 가능

### 설정
`/etc/gitlab/gitlab.rb`  
```ruby
gitlab_rails['monitoring_whitelist'] = ['127.0.0.0/8', '::1/128', '221.148.114.22/32']
```

<br>

## Endpoints를 local로 사용
기본 허용 목록 설정을 사용하면 다음 URLs를 사용하여 localhost에서 probes에 access 가능

```bash
GET http://localhost/-/health
GET http://localhost/-/readiness
GET http://localhost/-/liveness
```

<br>

## Health
Database나 다른 services가 실행 중인지 확인하지 않고 application server가 실행 중인지만 확인

```bash
GET /-/health
```

#### 요청 예시
```bash
curl "https://gitlab.example.com/-/health"
```

#### 응답 예시
```json
GitLab OK
```

<br>

## Readiness
Readiness probe는 GitLab insatnce가 Rails Controllers를 통해 traffic을 수락할 준비가 되었는지 확인

기본적으로 check는 instance-checks만 검증  
`all=1`이 매개변수로 지정된 경우, check는 종속 services(Database, Redis, Gitaly 등)의 유효성을 검증하고 각각에 대한 상태를 제공

```bash
GET /-/readiness
GET /-/readiness?all=1
```

#### 요청 예시
```bash
curl "https://gitlab.example.com/-/readiness"
```

#### 응답 예시
```json
{
   "master_check":[{
      "status":"failed",
      "message": "unexpected Master check result: false"
   }],
   ...
}
```

실패 시 endpoint는 `503` HTTP status code를 반환

<br>

## Liveness
Application server가 실행 중인지 확인  
이 probe는 Rails Controllers가 multi-threading으로 인해 교착 상태가 아닌지 확인하는 데 사용됩니다.

```bash
GET /-/liveness
```

#### 요청 예시
```bash
curl "https://gitlab.example.com/-/liveness"
```

#### 응답 예시
성공하면 endpoint는 `200` HTTP status code와 다음과 같은 응답 반환

```json
{
   "status": "ok"
}
```

실패 시 endpoint는 `503` HTTP status code를 반환

<br>

## Sidekiq
GitLab은 Sidekiq cluster에 대한 service health 및 reachability을 나타내는 liveness 및 readiness probes를 제공  
이러한 endpoints는 Kubernetes와 같은 schedulers에 제공되어 system이 준비될 때까지 traffic을 유지하거나 필요에 따라 container 재시작 가능

### Readiness
Readiness probe는 Sidekiq workers가 jobs를 처리할 준비가 되었는지 확인

```bash
GET /readiness
```

#### 요청 예시
Server가 `localhost:8092`에 binding된 경우 다음과 같이 process cluster에서 readiness 검색 가능

```bash
curl "http://localhost:8092/readiness"
```

#### 응답 예시
성공하면 endpoint는 `200` HTTP status code와 다음과 같은 응답 반환

```json
{
   "status": "ok"
}
```

<br>

## Liveness
Application server가 실행 중인지 확인  
Rails Controllers가 multi-threading으로 인해 교착 상태가 아닌지 확인

```bash
GET /-/liveness
```

#### 요청 예시
Server가 `localhost:8092`에 binding된 경우 다음과 같이 process cluster에서 liveness 검색 가능

```bash
curl "http://localhost:8092/liveness"
```

#### 응답 예시
성공하면 endpoint는 `200` HTTP status code와 다음과 같은 응답 반환

```json
{
   "status": "ok"
}
```

<hr>

## 참고
- **Health check** - https://docs.gitlab.com/ee/user/admin_area/monitoring/health_check.html
- **IP whitelist** - https://docs.gitlab.com/ee/administration/monitoring/ip_allowlist.html
- **Sidekiq Health Check** - https://docs.gitlab.com/ee/administration/sidekiq/sidekiq_health_check.html
