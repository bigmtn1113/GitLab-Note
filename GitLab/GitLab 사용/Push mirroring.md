# Push mirroring

<br>

Push mirror는 upstream repository에 대한 commits을 mirroring하는 downstream repository.  
Push mirrors는 upstream repository에 대한 commits의 복사본을 수동적으로 수신.  
Mirror가 upstream repository에서 분기되는 것을 방지하려면, commits를 downstream mirror로 직접 push하지 말고 upstream repository에 commits을 push.

Pull mirroring은 정기적으로 upstream repository에서 updates를 검색하지만, push mirrors는 다음과 같은 경우에만 변경 사항을 수신:
- Commits가 upstream GitLab repository로 push되는 경우.
- 관리자가 mirror를 강제 update한 경우.

Upstream repository에 변경 사항을 push하면, push mirror가 이를 수신:
- 5분 이내.
- **Only mirror protected branches**를 활성화한 경우, 1분 이내에 .

Branch가 기본 branch에 merge되어 source project에서 삭제되면, 다음 push 시 원격 mirror에서 삭제됨.  
Merge되지 않은 변경 사항이 있는 branch는 유지됨.  
Branch가 갈라지면, **Mirroring repositories** section에 오류가 표시됨.

<br>

## Push mirroring 구성
> [!NOTE]  
> Project에 대해 최소한 Maintainer role 필요.

1. 왼쪽 sidebar에서 **Search or go to**를 선택하고 project 찾기.
2. **Settings > Repository** 선택.
3. **Mirroring repositories** 확장.
4. Repository URL 입력.
5. **Mirror direction** dropdown 목록에서 **Push** 선택.
6. **Authentication method** 선택.
7. 필요한 경우, **Only mirror protected branches** 선택.
8. 원하는 경우, **Keep divergent refs** 선택.
9. 구성을 저장하려면, **Mirror repository** 선택.

### Protected branches만 mirroring
원격 repository에서 또는 원격 repository로, mirroring project의 protected branches만 mirroring하도록 선택 가능.  
Pull mirroring의 경우 mirroring project의 non-protected branches는 mirroring되지 않으며 분기될 수 있음.

이 option을 사용하려면 repository mirror를 생성할 때 **Only mirror protected branches** 선택.

<br>

## 2FA가 활성화된 다른 GitLab instance에 push mirror 설정
1. 대상 GitLab instance에서 `write_repository` 범위가 포함된 personal access token 생성.
2. Source GitLab instance에서 진행:
  1. 다음 형식을 사용하여 **Git repository URL** 입력:  
    `https://<destination host>/<your_gitlab_group_or_name>/<your_gitlab_project>.git.`
  2. **Username**에 `oauth2` 입력.
  3. **Password** 입력.  
    대상 GitLab instance에서 생성한 GitLab personal access token 사용.
  4. **Mirror repository** 선택.

<br>

## Mirror update
Mirror repository가 update되면 모든 새로운 branches, tags 및 commits가 project의 activity feed에 표시됨.  
GitLab의 repository mirror는 자동으로 update되며, update를 수동으로도 trigger 가능:
- GitLab.com에서는 최대 5분에 한 번.
- 자체 관리형 instances에 대해 관리자가 설정한 pull mirroring interval limit에 작동.

### 강제 update
Mirrors는 자동으로 update되도록 예약되어 있지만, 다음 경우를 제외하고는 즉시 update 강제 가능:
- Mirror가 이미 update 진행 중.
- Pull mirroring limits의 간격(초)가 마지막 update 이후 경과되지 않음.

> [!NOTE]  
> Project에 대해 최소한 Maintainer role 필요.

1. 왼쪽 sidebar에서 **Search or go to**를 선택하고 project 찾기.
2. **Settings > Repository** 선택.
3. **Mirroring repositories** 확장.
4. **Mirrored repositories**로 scroll하여 update할 mirror 식별.
5. **Update now** 선택:  
  ![image](https://docs.gitlab.com/ee/user/project/repository/mirror/img/repository_mirroring_force_update.png)

<hr>

## 참고
- **Repository mirroring** - https://docs.gitlab.com/ee/user/project/repository/mirror/
- **Push mirroring** - https://docs.gitlab.com/ee/user/project/repository/mirror/push.html
