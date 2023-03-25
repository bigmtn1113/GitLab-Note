# Amazon S3 사용 - Helm chart

<br>

GitLab은 Kubernetes의 고가용성 영구 data를 위해 객체 storage를 사용  
기본적으로 `minio`라고 명명된 S3 호환 storage solution이 chart와 함께 배포  
Production 환경의 경우 Google Cloud Storage 또는 AWS S3와 같은 hosted 객체 storage solution을 사용하는 것을 권장

MinIO를 비활성화하려면 다음과 같이 option을 설정
```bash
$ --set global.minio.enabled=false
```

또는

`values.yaml`  
```yaml
global:
  minio:
    enabled: false
```

<br>

## appConfig 설정
### 통합 객체 storage
객체 storage에 대한 공유 구성을 쉽게 사용 가능  
`object_store`를 사용하면 `connection`을 한 번만 구성해도 되며 `connection` 속성이 개별적으로 구성되지 않은 모든 객체 storage를 지원

`values.yaml`   
```yaml
global:
  appConfig:
    object_store:
      enabled: true
      proxy_download: true
      storage_options: {}
      connection: 
        secret: 
        key: 
```

속성 구조는 공유되며 다음과 같이 개별 항목에서 속성 재정의 가능  
`connection` 속성 구조가 동일

`values.yaml`   
```yaml
global:
  appConfig:
    artifacts:
      enabled: true
      proxy_download: true
      bucket: gitlab-artifacts
      connection: 
        secret: 
        key: 
```

### connection
`connection` 속성이 Kubernetes Secret으로 전환. 이 secret의 내용은 YAML 형식 file  
기본값은 `{}`이며 `global.minio.enabled`이 `true`면 무시됨

- `secret`은 Kubernetes Secret의 이름. 이 값은 외부 객체 storage를 사용하는데 필요
- `key`는 YAML block을 포함하는 secret의 key 이름. 기본값은 `connection`

`rails.s3.yaml`   
```yaml
provider: AWS
region: ap-northeast-2
use_iam_profile: true
# aws_access_key_id: BOGUS_ACCESS_KEY
# aws_secret_access_key: BOGUS_SECRET_KEY
```

`connection` 내용이 포함된 YAML file이 생성되면 이 file을 사용하여 Kubernetes에서 secret을 생성  
```bash
$ kubectl create secret generic gitlab-rails-storage \
    --from-file=connection=rails.yaml
```

<br>

## Backups
Backups는 객체 storage에도 저장되며 포함된 MinIO service가 아닌 외부를 가리키도록 구성 필요  
Backup/restore 절차는 두 개의 개별 bucket을 사용

- Backups를 저장하기 위한 bucket - global.appConfig.backups.bucket
- 복원 process 중 기존 data를 보존하기 위한 임시 bucket - global.appConfig.backups.tmpBucket

`gitlab.toolbox.backups.objectStorage.config` key를 통해 connection 구성 제공 필요

```bash
--set global.appConfig.backups.bucket=gitlab-backup-storage
--set global.appConfig.backups.tmpBucket=gitlab-tmp-storage
--set gitlab.toolbox.backups.objectStorage.config.secret=storage-config
--set gitlab.toolbox.backups.objectStorage.config.key=config
```
또는

`values.yaml`
```yaml
global:
  appConfig:
    backups:
      bucket: gitlab-backup-storage
      tmpBucket: gitlab-tmp-storage

gitlab:
  toolbox:
    backups:
      objectStorage:
        config:
          secret: storage-config
          key: config
```

### `storage.config` file 생성
`storage.config`  
```config
[default]
access_key = BOGUS_ACCESS_KEY
secret_key = BOGUS_SECRET_KEY
bucket_location = ap-northeast-2
multipart_chunk_size_mb = 128
```

multipart_chunk_size_mb의 기본값은 15 (MB)

### Secret 생성
```bash
$ kubectl create secret generic storage-config --from-file=config=storage.config
```

<hr>

## 참고
- **외부 객체 storage** - https://docs.gitlab.com/charts/advanced/external-object-storage/
- **통합 객체 storage** - https://docs.gitlab.com/charts/charts/globals.html#consolidated-object-storage
- **connection 속성** - https://docs.gitlab.com/charts/charts/globals.html#connection
