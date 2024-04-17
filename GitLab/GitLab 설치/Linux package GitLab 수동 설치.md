# Linux package GitLab 수동 설치

<br>

> [!NOTE]
> 수동 설치보다 패키지 저장소를 사용하는 것이 좋습니다.

어떤 이유로 공식 리포지토리를 사용하지 않는 경우 패키지를 다운로드하여 수동으로 설치할 수 있습니다. 이 방법은 GitLab을 처음 설치하거나 업그레이드하는 데 사용할 수 있습니다.

<br>

## 절차
1. 패키지의 공식 저장소를 방문하세요 .
2. 설치하려는 버전(예: 14.1.8)을 검색하여 목록을 필터링합니다. 단일 버전에 대해 지원되는 배포 및 아키텍처마다 하나씩 여러 패키지가 존재할 수 있습니다. 파일 이름 옆에는 배포를 나타내는 레이블이 있습니다. 파일 이름이 동일할 수 있기 때문입니다.
3. 설치하려는 패키지 버전을 찾고 목록에서 파일 이름을 선택하십시오.
4. 오른쪽 상단에서 다운로드 를 선택합니다 .
5. 패키지를 다운로드한 후 다음 명령 중 하나를 사용하고 <package_name>다운로드한 패키지 이름으로 바꿔 패키지를 설치합니다:

   ```bash
   # Debian/Ubuntu
   dpkg -i <package_name>

   # RHEL/CentOS 7 and Amazon Linux 2
   rpm -Uvh <package_name>

   # RHEL/Almalinux 8/9 and Amazon Linux 2023
   dnf install <package_name>

   # SUSE
   zypper install <package_name>
   ```

> [!NOTE]
> GitLab Community Edition gitlab-ee의 경우 gitlab-ce.

<hr>

## 참고
- **Linux package GitLab 수동 설치** - https://docs.gitlab.com/ee/update/package/#upgrade-using-a-manually-downloaded-package
