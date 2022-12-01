# gitlabrb_sanitizer

<br>

민감한 구성 변수를 수정하고 교체하여 `gitlab.rb` 파일을 소독  
Sanitizer는 `gitlab.rb` 파일 자체는 변경하지 않고 결과를 stdout에 출력

기밀 혹은 민감한 내용을 지우는 용도이나 `/etc/gitlab/gitlab.rb` 파일에서 수정한 내역 확인 용도로 사용 가능

<br>

## 사용법
```bash
$ cd /tmp

$ git clone --depth=1 https://gitlab.com/gitlab-com/support/toolbox/gitlabrb_sanitizer.git
$ cd gitlabrb_sanitizer

$ less sanitizer.rb # Please review before executing

$ ruby sanitizer.rb # --file /etc/gitlab/gitlab.rb is the default
```

### 옵션
```bash
$ ruby sanitizer.rb --help

Usage: sanitizer.rb [options]

Specific options:
    -f, --file FILE                  Sanitize FILE (default: /etc/gitlab/gitlab.rb)
    -s, --save FILE                  Save output to FILE (default: outputs to stdout)
    -d, --sanitize-domains           Sanitize domains
    -i, --sanitize-ips               Sanitize IP addresses
    -e, --sanitize-emails            Sanitize email addresses
    -h, --help                       Show this usage message and quit.
```

<br>

## 확인
### `/etc/gitlab/gitlab.rb` 파일 사본 생성 및 수정
```bash
$ cp /etc/gitlab/gitlab.rb /etc/gitlab/gitlab-test.rb
$ echo "test" >> /etc/gitlab/gitlab-test.rb
```

### Sanitizer 실행
```bash
$ ruby sanitizer.rb -f /etc/gitlab/gitlab-test.rb
```

### 결과
![image](https://user-images.githubusercontent.com/46125158/204969801-8ba4b2a5-e3a0-4595-aa8d-2b7c95ccbee7.png)

<hr>

## 참고
- **gitlabrb_sanitizer** - https://gitlab.com/gitlab-com/support/toolbox/gitlabrb_sanitizer
