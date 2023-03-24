# Omnibus to Helm chart migration

<br>

## 전제 조건
- Package 기반 GitLab instance가 반드시 실행 중이어야 하며, `gitlab-ctl status` 실행 후 `down` 표시가 된 서비스가 없는지 확인
- Git repository 무결성 확인 권장
- Package 기반 설치와 동일한 GitLab version을 실행하는 helm chart 기반 배포 필요
- Helm chart 기반 배포에서 사용할 객체 storage 설정 필요  
  Production 환경의 경우 외부 객체 storage 사용 권장

<br>

## Migration
1. **Package 기반 설치에서 객체 storage로 기존 data를 migration**

2. **Backup tarball 생성**
    ```bash
    $ sudo gitlab-backup create
    ```
    
    명시적으로 변경하지 않는 한 backup file은 `/var/opt/gitlab/backups`에 저장

3. **Secrets부터 시작하여 package 기반 설치에서 Helm chart로 backup 복원**  

    Helm에서 사용할 YAML file로 `/etc/gitlab/gitlab-secrets.json` 값 migration

4. **모든 pods을 다시 시작하여 변경사항이 적용되었는지 확인**
    ```bash
    $ kubectl delete pods -lrelease=<helm release name>
    ```

5. **Package 기반 설치에 존재했던 projects, groups, users, issues 등이 복원되었는지 확인**  

    또한 uploade된 files(avatars, issues에 upload된 files 등)가 잘 load되는지 확인

<hr>

## 참고
- **Linux package에서 Helm chart로 migration** - https://docs.gitlab.com/charts/installation/migration/package_to_helm.html
