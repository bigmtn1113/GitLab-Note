# Linux package GitLab 수동 설치

<br>

> [!NOTE]
> 수동 설치보다 package repository를 사용하는 것을 권장.

어떤 이유로 공식 repositories를 사용하지 않는 경우, package를 download하여 수동으로 설치 가능.  
GitLab을 처음 설치하거나 upgrade하는 데 사용 가능.

<br>

## 절차
1. package의 [official repository](https://packages.gitlab.com/gitlab/) 방문.
2. 설치하려는 version(ex: 14.1.8)을 검색하여 목록을 Filltering.  
   단일 version에 대해 지원되는 배포 및 architecture마다 하나씩 여러 package가 존재할 수 있음. File 이름이 동일할 수 있으므로, 옆에는 배포를 나타내는 lable이 존재.
3. 설치하려는 package version을 찾고 목록에서 file 이름을 선택.
4. 오른쪽 상단에서 **Download**를 선택.
5. Package를 download한 후, 다음 명령 중 하나를 사용하고 `<package_name>`를 download한 package 이름으로 바꿔 package를 설치:

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
> GitLab Community Edition의 경우 `gitlab-ee`를 `gitlab-ce`로 변경.

<hr>

## 참고
- **Linux package GitLab 수동 설치** - https://docs.gitlab.com/ee/update/package/#upgrade-using-a-manually-downloaded-package
