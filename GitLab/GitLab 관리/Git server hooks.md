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

<hr>

## 참고
- **Git server hooks** - https://docs.gitlab.com/ee/administration/server_hooks.html
- **Server-Side Hooks** - https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks#_server_side_hooks
- **pre-receive-hooks script** - https://github.com/github/platform-samples/tree/master/pre-receive-hooks
