# Minio PV 자동 삭제 방지 - Helm chart
Helm chart를 지울 때마다 Minio PV까지 사라져, data 손실이 발생하는 issue 존재.

<br>

## Point
- `global.minio`는 `enabled` 설정이 주고, 그 외 설정은 minio chart에서 주로 설정.
- `minio.persistence.annotaions.helm.sh/resource-policy: keep`이 설정되어 있어도, StorageClass의 policy가 `Delete`면 PV는 지워짐.
- `Released` 상태인 PV는 재사용할 수 없으므로, PV yaml에서 `spec.claimRef` 부분 삭제해 `Available` 상태로 만들어서 재사용.
- Dynamic Provisioning은 PVC가 생기면 StorageClass가 PV를 자동으로 생성해 주나, Static Provisiong은 PV를 미리 만들어두면 PVC가 생겼을 때 그 PV와 binding됨.
  - PVC까지 수동으로 만들기보단, PVC는 Helm chart에서 자동으로 생성되도록 하는 것이 표준이면서 안정적.
  - 이미 PVC가 만들어져 있다면 지우고 권장 사항대로 진행.
- Dynamic Provisioning를 수행하기 위해선 StorageClass가 필요하나, Static Provisioning은 PV가 이미 있으니 불필요.
  - Default StorageClass가 있는 경우엔 이 StorageClass를 자동으로 사용하게 될 수 있고, 아니면 class matching이 실패할 수 있는 조건이 있을 수 있으니, StorageClass는 상황에 따라 명시적 기입 필요.

<br>

## 사전 작업
정상 작동하는 Helm chart 준비.

<br>

## Test case 1
Helm chart를 지워도 PV는 보존되도록 설정:
1. 기존에 사용하고 있던 StorageClass 복사 후, `reclaimPolicy`를 `Retain`으로 변경:
   ```
   ...
   reclaimPolicy: Retain
   ...
   ```
   
2. 신규 생성한 StorageClass를 사용할 수 있도록 `values.yaml` 수정:
   ```
   ...
   minio:
     persistence:
       storageClass: <New StorageClass name>
       size: 10Gi
   ```
   
3. Helm chart install 후, 삭제.

4. PVC는 사라지나, PV는 Release 상태로 남아 있는 것 확인.

<br>

## Test case 2
Release 상태인 PV를 그대로 사용:
1. `Released` PV를 `Available` PV로 변경하기 위해, PV yaml에서 `spec.claimRef` 부분 삭제:
   ```
   spec:
     ...
     claimRef:
       apiVersion: v1
       kind: PersistentVolumeClaim
       name: xxx
       namespace: xxx
       resourceVersion: 'xxx'
       uid: xxx
   ```
   
2. PV가 `Available` 상태로 변경됐는지 확인.

3. `Available` PV를 사용할 수 있도록 `values.yaml` 수정:
   ```
   minio:
     persistence:
       storageClass: <New StorageClass name>  # Default StorageClass가 사용되지 않도록, 명시적 기입.
       volumeName: <Available PV>
   ```
   
4. Helm chart install하면, PVC가 자동으로 생성되고 `Available` PV가 `Bound` 되는 것 확인.

<br>

## Test case 3
수동으로 생성한 PV와 PVC가 있을 경우:
1. PV yaml에 가서 `spec.StorageClassName` 확인(e.g., `no-use`).

2. 기존 PVC 삭제.

3. PV 상태가 `Released`로 변한 것 확인.

4. `Released` PV를 `Available` PV로 변경하기 위해, PV yaml에서 `spec.claimRef` 부분 삭제.
   ```
   spec:
     ...
     claimRef:
       apiVersion: v1
       kind: PersistentVolumeClaim
       name: xxx
       namespace: xxx
       resourceVersion: 'xxx'
       uid: xxx
   ```
   
5. PV가 `Available` 상태로 변경됐는지 확인.

6. `Available` PV를 사용할 수 있도록 `values.yaml` 수정:
   ```
   minio:
     persistence:
       storageClass: <PV StorageClass name>  # Default StorageClass가 사용되지 않도록, 명시적 기입. e.g., no-use
       volumeName: <Available PV>
   ```
   
7. Helm chart install하면, PVC가 자동으로 생성되고 `Available` PV가 `Bound` 되는 것 확인.
