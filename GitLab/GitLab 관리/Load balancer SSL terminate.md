# Load balancer SSL terminate

<br>

## Backend SSL 없이 load balancer SSL 종료
`TCP`대신 `HTTP(S)` protocol을 사용하도록 load balancer를 구성  
Load balancer는 SSL 인증서 관리 및 SSL 종료를 담당  
Load balancer와 GitLab 간의 통신은 안전하지 않기 때문에 몇 가지 추가 구성이 필요

<br>

## Reverse proxy 또는 load balancer SSL 종료 구성
기본적으로 Omnibus GitLab은 `external_url`에 `https://`가 포함된 경우 SSL을 사용할지 여부를 자동 감지하고 SSL 종료를 위해 NGINX를 구성  
그러나 reverse proxy 또는 외부 load balancer 뒤에서 실행되도록 GitLab을 구성하는 경우 일부 환경에서는 GitLab 애플리케이션 외부에서 SSL을 종료해야 할 필요성 존재

※ ACM(AWS Certificate Manager)과 같은 일부 클라우드 제공자 서비스에서는 인증서 다운로드를 허용하지 않으므로 GitLab 인스턴스에서 SSL 종료 사용 불가.
이러한 클라우드 서비스와 GitLab 간에 SSL이 필요한 경우 GitLab 인스턴스에서 다른 인증서를 사용

### Bundled NGINX가 SSL 종료 처리하는 것을 방지
`/etc/gitlab/gitlab.rb`
```ruby
nginx['listen_port'] = 80
nginx['listen_https'] = false
```

Container Registry, GitLab Pages 또는 Mattermost와 같은 다른 bundled components도 proxied SSL에 유사한 전략을 사용  
특정 components의 `*_external_url`을 `https://`로 설정하고 `nginx[...]` 구성에 component 이름을 접두사로 붙여서 사용

#### GitLab Container Registry example
`/etc/gitlab/gitlab.rb`
```ruby
registry_external_url 'https://registry.example.com'

registry_nginx['listen_port'] = 80
registry_nginx['listen_https'] = false
```

※ Registry NGINX가 80으로 받고 Container Registry는 registry default port인 5000에서 작동

<br>

## ※ `docker-compose.yml` 예시
```yaml
version: '3.6'
services:
  web:
    image: 'gitlab/gitlab-ee:latest'
    restart: always
    hostname: 'gitlab.example.com'
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'https://gitlab.example.com'

        letsencrypt['enable'] = false

        nginx['listen_port'] = 80
        nginx['listen_https'] = false
        nginx['redirect_http_to_https'] = false

        registry_external_url 'https://registry.example.com'

        registry_nginx['listen_port'] = 80
        registry_nginx['listen_https'] = false
        registry_nginx['redirect_http_to_https'] = false
    ports:
      - '80:80'
      - '2222:22'
    volumes:
      - '/srv/gitlab/config:/etc/gitlab'
      - '/srv/gitlab/logs:/var/log/gitlab'
      - '/srv/gitlab/data:/var/opt/gitlab'
    shm_size: '256m'

```

### Let's Encrypt 통합 비활성화
GitLab은 재구성할 때마다 Let's Encrypt 인증서를 갱신하려고 시도  
수동으로 생성한 인증서를 사용하려는 경우 Let's Encrypt 통합을 비활성화 필요  
그렇지 않으면 자동 갱신으로 인해 인증서를 덮어쓸 가능성 존재

### Redirect HTTP requests to HTTPS
기본적으로 `external_url`시작을 `https`로 지정하면 NGINX는 더 이상 80번 포트에서 암호화되지 않은 HTTP 트래픽을 수신 대기하지 않으므로 모든 HTTP 트래픽을 HTTPS로 리디렉션하려면 `nginx['redirect_http_to_https'] = true`로 설정  
그러나 load balancer가 SSL 종료를 처리하면 https redirect 비활성화

<hr>

## 참고
- Backend SSL 없이 LB SSL 종료 - https://docs.gitlab.com/ee/administration/load_balancer.html#load-balancers-terminate-ssl-without-backend-ssl
- Reverse proxy 또는 load balancer SSL 종료 구성 - https://docs.gitlab.com/omnibus/settings/ssl/index.html#configure-a-reverse-proxy-or-load-balancer-ssl-termination
