# Linux package (Omnibus) 제거

<br>

Linux pacakge를 제거할 때, data(repositories, database, configuration)를 유지하거나 모두 제거하도록 선택 가능.

<br>

## 절차
1. 선택 사항. `apt` 또는 `yum`으로 pacakge를 제거하기 전에 Linux pacakge에서 생성된 모든 users 및 groups 제거:
    
    ```
    sudo gitlab-ctl stop && sudo gitlab-ctl remove-accounts
    ```

    > [!NOTE]  
    > 계정이나 groups를 제거하는데 문제가 있는 경우 `userdel` 또는 `groupdel`을 실행하여 수동으로 삭제 수행.
    > `/home/`에서 남은 user home directories를 수동으로 제거 가능.

2. Data를 유지할지 아니면 모두 삭제할지 선택해서 진행.
    - Data(repositories, database, configuration)를 보존하려면 GitLab을 중지하고 supervision process 제거:
    
      ```
      sudo systemctl stop gitlab-runsvdir
      sudo systemctl disable gitlab-runsvdir
      sudo rm /usr/lib/systemd/system/gitlab-runsvdir.service
      sudo systemctl daemon-reload
      sudo systemctl reset-failed
      sudo gitlab-ctl uninstall
      ```
    - 모든 data를 제거:
      ```
      sudo gitlab-ctl cleanse && sudo rm -r /opt/gitlab
      ```

3. Pacakge 제거(GitLab FOSS가 설치된 경우 `gitlab-ce`로 교체):
    
    ```
    # Debian/Ubuntu
    sudo apt remove gitlab-ee
    
    # RedHat/CentOS
    sudo yum remove gitlab-ee
    ```

<hr>

## 참고
- **Uninstall the Linux package (Omnibus)** - https://gitlab.com/gitlab-org/omnibus-gitlab/-/blob/master/doc/installation/index.md#uninstall-the-linux-package-omnibus
