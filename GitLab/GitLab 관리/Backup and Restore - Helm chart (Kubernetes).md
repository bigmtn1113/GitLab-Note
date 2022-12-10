# Backup and Restore - Helm chart (Kubernetes)

<br>

## Backup
GitLab 백업은 chart에 제공된 Toolbox pod에서 `backup-utility` 명령을 실행하여 수행

### Backup 생성
#### 1. toolbox pod가 실행 중인지 확인
```bash
kubectl get pods -lrelease=RELEASE_NAME,app=toolbox
```

#### 2. Backup utility 실행
```bash
kubectl exec <Toolbox pod name> -it -- backup-utility
```

#### 3. Backup file 확인
```bash
ls /srv/gitlab/tmp/backups
```

### Secrets Backup
보안 예방 조치로 백업에 포함되지 않은 rails secrets의 복사본 저장 필요  
데이터베이스를 포함하는 전체 백업을 secrets 복사본과 별도로 보관하는 것을 권장

#### 1. Rails secrets 조회
```bash
kubectl get secrets | grep rails-secret
```

#### 2. Rails secrets 복사본 저장
```bash
kubectl get secrets <rails-secret-name> -o jsonpath="{.data['secrets\.yml']}" | base64 --decode > gitlab-secrets.yaml
```

<br>

## Restore
GitLab 백업 복원은 chart에 제공된 Toolbox pod에서 `backup-utility` 명령을 실행하여 수행

### Rails secrets 복원
#### 1. Rails secrets 조회
```bash
kubectl get secrets | grep rails-secret
```

#### 2. 기존 secret 삭제
```bash
kubectl delete secret <rails-secret-name>
```

#### 3. 이전과 동일한 이름을 사용하여 새 secret을 생성하고 로컬 yaml 파일을 전달
```bash
kubectl create secret generic <rails-secret-name> --from-file=secrets.yml=gitlab-secrets.yaml
```

### Pod 재시작
새로운 secret을 적용하기 위해 Webservice, Sidekiq, Toolbox pod 재시작 필요

```bash
kubectl delete pods -lapp=sidekiq,release=<helm release name>
kubectl delete pods -lapp=webservice,release=<helm release name>
kubectl delete pods -lapp=toolbox,release=<helm release name>
```

### Backup file 복원
#### 1. toolbox pod가 실행 중인지 확인
```bash
kubectl get pods -lrelease=RELEASE_NAME,app=toolbox
```

#### 2. Backup file 확인
```bash
ls /srv/gitlab/tmp/backups
```

#### 3. Backup utility를 이용해 Backup file 복원
```bash
kubectl exec <Toolbox pod name> -it -- backup-utility --restore -t <timestamp>_<version>
```

<hr>

## 참고
- **Backup** - https://docs.gitlab.com/charts/backup-restore/backup.html
- **Restore** - https://docs.gitlab.com/charts/backup-restore/restore.html
