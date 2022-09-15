# Amazon EC2 위에 Docker로 GitLab 설치.md

## Architecture 참고
![Image](https://user-images.githubusercontent.com/46125158/182595173-d38263c1-163e-4eac-944c-1dd34b7d0c5e.png)

<hr>

## 전제 조건
### docker 설치
```bash
sudo amazon-linux-extras install -y docker
sudo systemctl enable docker
sudo systemctl start docker

# sudo를 사용하지 않고도 Docker 명령을 실행할 수 있도록 docker 그룹에 ec2-user 추가
sudo usermod -a -G docker ec2-user

# terminal 재시작 후, 진행
docker info
```

### docker compose 설치
```bash
# 버전명이 아닌 latest로 다운로드하면 docker-compose 명령어를 찾지 못하는 에러 발생
sudo curl -L https://github.com/docker/compose/releases/download/v2.9.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose
docker-compose version

```
※ latest 에러 메시지 - `/usr/local/bin/docker-compose: line 1: Not: command not found`

<hr>

## GitLab 설치
### 볼륨 위치 설정
```bash
sudo mkdir /srv/gitlab
```

### `docker-compose.yml` 파일 작성
```yaml
services:
  web:
    image: 'gitlab/gitlab-ee:latest'
    restart: always
    hostname: 'gitlab.example.com'
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'https://gitlab.example.com'
    ports:
      - '80:80'
      - '2222:22'
    volumes:
      - '/srv/gitlab/config:/etc/gitlab'
      - '/srv/gitlab/logs:/var/log/gitlab'
      - '/srv/gitlab/data:/var/opt/gitlab'
```

hostname, external_url에서 [gitlab.example.com](http://gitlab.example.com)은 사용할 도메인으로 변경  
gitlab을 설치한 ec2 인스턴스의 ssh 포트를 22번으로 사용하고 있다면 포트 변경 필수. ex) 2222

<br>

## GitLab 설정 파일 수정
### `/srv/gitlab/config/gitlab.rb` 파일 수정
※ container 내부에서의 경로는 `/etc/gitlab/gitlab.rb`

```ruby
...
nginx['redirect_http_to_https'] = false
...
nginx['listen_port'] = 80
...
nginx['listen_https'] = false
...
nginx['proxy_set_headers'] = { "X-Forwarded-Proto" => "https", "X-Forwarded-Ssl" => "on" }
...
letsencrypt['enable'] = false
...
```
EC2(GitLab)로 오는 트래픽은 ELB를 거치게 되는데 이 ELB의 443 포트 리스너는 ACM에서 발급 받은 인증서를 사용중  
이 ELB가 443번 포트 접근 트래픽을 EC2의 80번 포트로 전달하므로 EC2 자체에서 SSL/TLS 관련 설정할 필요가 없음  
- http를 https로 redirect X
- https 활성화 X
- 무료 SSL/TLS 인증서를 사용할 수 있게 해주는 Let's Encrypt 사용 X

※ **X-Forwarded-Proto**  
서버 액세스 로그에는 서버와 로드 밸런서 간에 사용되는 프로토콜만 포함  
여기에는 클라이언트와 로드 밸런서 간에 사용되는 프로토콜에 대한 정보가 포함되어 있지 않음  
클라이언트와 로드 밸런서 간에 사용된 프로토콜 확인을 위한 X-Forwarded-Proto 설정

<br>

## GitLab 시작 및 확인
```bash
docker-compose up -d

# STATUS가 healthy인지 확인
docker ps
```

### GitLab 접속
docker-compose.yml 파일에 적은 external_url로 접속
```yaml
external_url 'https://gitlab.example.com'
```
![image](https://user-images.githubusercontent.com/46125158/182332529-701c321f-4669-4206-89e8-ede054317f03.png)

### ※ root 초기 패스워드 확인
```bash
sudo docker exec -it <container name> grep 'Password:' /etc/gitlab/initial_root_password
```

<hr>

## 참고
- **GitLab Docker image를 이용한 GitLab 설치** - https://docs.gitlab.com/ee/install/docker.html
- **X-Forwarded-Proto** - https://docs.aws.amazon.com/elasticloadbalancing/latest/application/x-forwarded-headers.html#x-forwarded-proto
