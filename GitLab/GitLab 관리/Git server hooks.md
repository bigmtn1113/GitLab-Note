# Git server hooks

<br>

## Repository에 대한 server hooks 생성
1. 상단표시줄에서 **Main menu > Admin** 선택
2. **Overview > Projects**로 이동 후 server hook를 추가할 프로젝트 선택
3. 표시되는 페이지에서 **Gitaly relative path**값 확인. 이 경로는 server hook가 있어야 하는 위치
4. 파일 시스템에서 올바른 위치(`/var/opt/gitlab/git-data/repositories/<gitaly relative path>`)에 `custom_hooks`라는 새 디렉토리 생성
5. `custom_hooks` 디렉토리에 hook type(`pre-receive`, `update`, `post-receive`)과 일치하는 이름으로 파일 생성  
    - 파일 이름에 확장자가 없어야 하는 것이 조건
      - ex) `pre-receive`
    - 많은 server hooks를 생성하려면 디렉터리로 생성
      - ex) `pre-receive.d`
    - hook에 대한 파일들을 해당 디렉터리에 위치
6. **Server hook 파일을 실행 가능**하게 만들고 Git 사용자가 파일을 소유하는지 확인
7. Server hook가 예상대로 작동하도록 코드 작성

<br>

## Test
### pre-receive 코드 작성
어떤 경우라도 `exit 1`로 return하면서 Read-only 권한만 가지도록 설정하는 코드 작성  
return 값이 0일 경우에만 push 가능

```bash
#!/usr/bin/env bash

#
# Pre-receive hook that will reject all pushes
# Useful for locking a repository
#
# More details on pre-receive hooks and how to apply them can be found on
# https://help.github.com/enterprise/admin/guides/developer-workflow/managing-pre-receive-hooks-on-the-github-enterprise-appliance/
#

echo "You are attempting to push to the ${GITHUB_REPO_NAME} repository which has been made read-only"
echo "Access denied, push blocked. Please contact the repository administrator."

exit 1
```

### git push
![image](https://user-images.githubusercontent.com/46125158/219855030-7e8a2ed6-c712-4166-afba-83a1b27d448a.png)

<hr>

## 참고
- **Git server hooks** - https://docs.gitlab.com/ee/administration/server_hooks.html
- **Server-Side Hooks** - https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks#_server_side_hooks
- **pre-receive-hooks script** - https://github.com/github/platform-samples/tree/master/pre-receive-hooks
