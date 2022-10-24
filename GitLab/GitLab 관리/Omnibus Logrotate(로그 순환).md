# Omnibus Logrotate(로그 순환)

`gitlab-rails/production.log`와 `nginx/gitlab_access.log`와 같은 log data를 순환, 압축 및 삭제  
최근 로그 유지 및 지속적으로 쌓이는 로그 컨트롤 가능

<br>

## 일반적인 logrotate 설정 구성
모든 logrotate 서비스에 공통적인 설정은 `/etc/gitlab/gitlab.rb` 파일에서 설정 가능

```ruby
logging['logrotate_frequency'] = "daily" # rotate logs daily
logging['logrotate_maxsize'] = nil # logs will be rotated when they grow bigger than size specified for `maxsize`, even before the specified time interval (daily, weekly, monthly, or yearly)
logging['logrotate_size'] = nil # do not rotate by size by default
logging['logrotate_rotate'] = 30 # keep 30 rotated logs
logging['logrotate_compress'] = "compress" # see 'man logrotate'
logging['logrotate_method'] = "copytruncate" # see 'man logrotate'
logging['logrotate_postrotate'] = nil # no postrotate command by default
logging['logrotate_dateformat'] = nil # use date extensions for rotated files rather than numbers e.g. a value of "-%Y-%m-%d" would give rotated files like production.log-2016-03-09.gz
```

### ※ logrotate 설정 구성에 따라 30일 기준으로 log 저장
![image](https://user-images.githubusercontent.com/46125158/197501291-9f4e6ded-1176-49b6-869b-7ec7109dbc2d.png)

<br>

## logrotate 비활성화
`/etc/gitlab/gitlab.rb`에서 설정 가능

```ruby
logrotate['enable'] = false
```

<hr>

## 참고
- **Logrotate** - https://docs.gitlab.com/omnibus/settings/logs.html#logrotate
