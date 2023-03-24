# Backup and Restore - Helm chart (Kubernetes)

<br>

## Backup
GitLab backup은 chart에 제공된 Toolbox pod에서 `backup-utility` 명령을 실행하여 수행  
Backup을 실행하기 전에 Toolbox가 객체 storage에 access할 수 있도록 올바르게 구성되었는지 확인

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
객체 storage service에서 `gitlab-backups` bucket을 방문하여 `<timestamp>_gitlab_backup.tar` 형식의 이름을 가진 tarball이 추가되었는지 확인  

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
새로운 secrets를 적용하기 위해 Webservice, Sidekiq 및 Toolbox pods 재시작

```bash
kubectl delete pods -lapp=sidekiq,release=<helm release name>
kubectl delete pods -lapp=webservice,release=<helm release name>
kubectl delete pods -lapp=toolbox,release=<helm release name>
```

### Backup file 복원
#### 1. Toolbox pod가 실행 중인지 확인
```bash
kubectl get pods -lrelease=RELEASE_NAME,app=toolbox
```

#### 2. 다음 위치에 tarball 준비
tarball이 `<timestamp>_gitlab_backup.tar` 형식의 이름으로 지정되어 있는지 확인

#### 3. Backup utility를 이용해 traball 복원
```bash
kubectl exec <Toolbox pod name> -it -- backup-utility --restore -t <timestamp>
```

복원 process는 database의 기존 내용을 지우고 기존 repository를 임시 위치로 이동시킨 후 tarball의 내용을 추출  
Repository는 disk의 해당 위치로 이동되고 artifaces, uploads, LFS 등과 같은 기타 data는 객체 storage의 해당 bucket에 업로드됨

<hr>

## 참고
- **Backup** - https://docs.gitlab.com/charts/backup-restore/backup.html
- **Restore** - https://docs.gitlab.com/charts/backup-restore/restore.html
