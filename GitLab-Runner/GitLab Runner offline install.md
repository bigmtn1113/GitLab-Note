# GitLab Runner offline install
deb/rpm repository를 사용하여 GitLab Runner를 설치할 수 없거나, GNU/Linux OS가 지원되는 OS가 아닌 경우 최후의 수단으로 아래 방법 중 하나를 사용하여 수동으로 설치 가능.

<br>

## 사전 작업
### OS 확인
적절한 download file을 설치하기 위해 구축 환경의 OS 확인:

```shell
cat /etc/*release*

uname -a
```

<br>

### Download file 확인
1. [GitLab Runner download file 저장소](https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/latest/index.html)에서 설치할 최신 file name 및 option 조회.
2. [Tags 목록](https://gitlab.com/gitlab-org/gitlab-runner/-/tags)에서 GitLab Runner tags에 대한 정보 확인.

<br>

## deb/rpm package 사용
### Download
이전에 조회했던 file을 참고하여, `main`을 다른 `tag`(e.g., `v16.5.0`)나 `latest`로 교체하고 `${arch}`를 적절한 architecture 값으로 대체해서 download:
- Debian 또는 Ubuntu:
  ```shell
  curl -LJO "https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/main/deb/gitlab-runner-helper-images.deb"
  curl -LJO "https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/main/deb/gitlab-runner_${arch}.deb"
  ```

- Red Hat 또는 CentOS:
  ```shell
  curl -LJO "https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/main/rpm/gitlab-runner-helper-images.rpm"
  curl -LJO "https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/main/rpm/gitlab-runner_${arch}.rpm"
  ```

e.g.
- Debian 또는 Ubuntu에 amd64, tag은 18.0.1:
  ```shell
  curl -LJO "https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/v18.0.1/deb/gitlab-runner-helper-images.deb"
  curl -LJO "https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/v18.0.1/deb/gitlab-runner_amd64.deb"
  ```

- Red Hat 또는 CentOS에 amd64, tag은 18.0.1:
  ```shell
  curl -LJO "https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/v18.0.1/rpm/gitlab-runner-helper-images.rpm"
  curl -LJO "https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/v18.0.1/rpm/gitlab-runner_amd64.rpm"
  ```

<br>

### Install
System에 맞는 package install.

- Debian 또는 Ubuntu:
  ```shell
  dpkg -i gitlab-runner-helper-images.deb gitlab-runner_<arch>.deb
  ```

- Red Hat Enterprise Linux 또는 CentOS:
  ```shell
  dnf install -y gitlab-runner-helper-images.rpm gitlab-runner_<arch>.rpm
  ```

<br>

### Upgrade
System에 맞는 최신 package를 download한 후, 다음과 같이 진행.

- Debian 또는 Ubuntu:
  ```shell
  dpkg -i gitlab-runner-helper-images.deb gitlab-runner_<arch>.deb
  ```

- Red Hat Enterprise Linux 또는 CentOS:
   ```shell
   dnf install -y gitlab-runner-helper-images.rpm gitlab-runner_<arch>.rpm
   ```

<br>

## Binary file 사용
### Install
1. System에 맞는 binary download:
   ```shell
   sudo curl -L --output /usr/local/bin/gitlab-runner "https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/latest/binaries/gitlab-runner-linux-amd64"
   ```

2. 실행 권한 부여:
   ```shell
   sudo chmod +x /usr/local/bin/gitlab-runner
   ```

3. GitLab CI user 생성:
   ```shell
   sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
   ```

4. Service로 설치 및 실행:
   ```shell
   sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
   sudo gitlab-runner start
   ```

<br>

### Upgrade
1. Service 중지:
   ```shell
   sudo gitlab-runner stop
   ```

2. 대체할 GitLab Runner file download:
   ```shell
   sudo curl -L --output /usr/local/bin/gitlab-runner "https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/latest/binaries/gitlab-runner-linux-amd64"
   ```

3. 실행 권한 부여:
   ```shell
   sudo chmod +x /usr/local/bin/gitlab-runner
   ```

4. Service 시작:
   ```shell
   sudo gitlab-runner start
   ```
<hr>

## 참고
- [Install GitLab Runner manually on GNU/Linux](https://docs.gitlab.com/runner/install/linux-manually/)
- [GitLab Runner bleeding edge releases](https://docs.gitlab.com/runner/install/bleeding-edge/)
