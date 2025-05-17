# Upgrade 전후 점검
Upgrade 바로 전후에, GitLab의 주요 구성 요소가 작동하는지 확인하기 위해 점검 수행.

<br>

1. 일반 구성 확인:
   ```Shell
   sudo gitlab-rake gitlab:check
   ```

2. 암호화된 databse 값을 해독할 수 있는지 확인:
   ```Shell
   sudo gitlab-rake gitlab:doctor:secrets
   ```

3. GitLab UI에서, 다음을 확인:
   - Users가 login 가능한지.
   - Project list가 표시되는지.
   - Project issues와 merge requests에 접근 가능한지.
   - Users가 GitLab repositories를 clone할 수 있는지.
   - Users가 GitLab에 commits을 push할 수 있는지.

4. GitLab CI/CD의 경우, 다음을 확인:
   - Runners가 jobs를 pick up할 수 있는지.
   - Docker images를 registry로/에서 push/pull할 수 있는지.

5. Geo를 사용하는 경우, primary 및 각 secondary에서 관련 점검 실행:
   ```Shell
   sudo gitlab-rake gitlab:geo:check
   ```

6. Elasticsearch를 사용하는 경우, 검색이 성공적인지 확인.

<hr>

## 참고
- **[Pre-upgrade and post-upgrade checks](https://docs.gitlab.com/update/#pre-upgrade-and-post-upgrade-checks)**
