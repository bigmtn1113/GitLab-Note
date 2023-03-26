# Daily backup을 위한 cron 구성 - Helm chart

GitLab backups는 chart에 제공된 Toolbox pod에서 `backup-utility` 명령을 실행하여 수행  
이 chart의 Cron 기반 backup 기능을 활성화하여 백업 자동화 가능

Backup을 실행하기 전에 Toolbox가 객체 storage에 access할 수 있도록 [올바르게 구성](https://github.com/bigmtn1113/GitLab-Note/blob/master/GitLab/GitLab%20%EA%B4%80%EB%A6%AC/Amazon%20S3%20%EC%82%AC%EC%9A%A9%20-%20Helm%20chart.md)되었는지 확인

<br>

## `values.yaml` 예제
`values.yaml`  
```yaml
gitlab:
  toolbox:
    replicas: 1
    antiAffinityLabels:
      matchLabels:
        app: gitaly
    backups:
      objectStorage:
        config:
          secret: storage-config
          key: config
      cron:
        enabled: true
        concurrencyPolicy: Replace
        failedJobsHistoryLimit: 1
        schedule: "* 1 * * *"
        successfulJobsHistoryLimit: 3
        suspend: false
        backoffLimit: 6
        safeToEvict: false
        restartPolicy: "OnFailure"
        resources:
          requests:
            cpu: 50m
            memory: 350M
        persistence:
          enabled: false
          accessMode: ReadWriteOnce
          size: 10Gi
```

<hr>

## 참고
- **Helm chart 설치 Backup** - https://docs.gitlab.com/charts/backup-restore/backup.html
- **Toolbox chart** - https://docs.gitlab.com/charts/charts/gitlab/toolbox/
