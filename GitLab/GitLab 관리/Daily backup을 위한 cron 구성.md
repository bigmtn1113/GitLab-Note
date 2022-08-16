# Daily backup을 위한 cron 구성

<br>

CI/CD 시크릿 변수, two-factor 인증 정보 등과 같은 정보들은 명령어로 자동으로 백업 되지 않으니 별도로 백업 진행해야 하나,  
Docker Container 내에서 GitLab을 실행 할 때 마운트를 진행했으므로 마운트한 경로(/srv/gitlab/config)에 자동으로 저장됨

※ 즉, 다음 cron 작업은 GitLab 구성 파일 또는 SSH 호스트 키를 백업하지 않음

<hr>

## 구성 현황
- **GitLab 버전 - 최소 12.2**
- **Docker Container 내에서 GitLab 실행**

<hr>

## root 사용자의 crontab 편집
```bash
sudo su -
crontab -e
```

```bash
# 매일 오전 6시에 backup 수행
0 6 * * * /usr/bin/docker exec -it <container name> /opt/gitlab/bin/gitlab-backup create CRON=1
```
※ `CRON=1` 옵션은 오류가 없는 경우 backup script가 모든 진행 출력을 숨기도록 지시. cron spam을 줄이기 위해 권장


<hr>

## 참고
- **Daily backup을 위한 cron 구성** - https://docs.gitlab.com/ee/raketasks/backup_gitlab.html#configuring-cron-to-make-daily-backups
- **구성 파일 저장** - https://docs.gitlab.com/ee/raketasks/backup_gitlab.html#storing-configuration-files
