# Git repository에 있는 commits history 삭제

<br>

## 1. Local에서 commits 삭제
> [!NOTE]  
> `git status` 명령을 사용하여 working directory에 변경 사항이 없는지 확인.  
> 삭제 후 `git log`를 통해 commits history가 지워졌는지 확인.

<br>

### 연속된 commits 삭제
- 최신 commit 삭제  
  ```
  git reset --hard HEAD~1
  ```
- 최근 여러 개의 commits 삭제
  ```
  git reset --hard HEAD~<숫자>
  ```

<br>

### 비연속 commits 삭제
- 특정 commmit 삭제  
  ```
  git reset --hard <hash>
  ```
  ※ hash는 `git log`에서 확인.
- 여러개의 특정 commits 삭제
  ```
  git rebase -i <삭제하려는 commit의 이전 commit hash>
  ```
  대화형 rebase에서 삭제하고 싶은 commits(밑으로 갈수록 최신)를 찾아서 pick을 drop으로 수정.
  그 후, 저장하고 종료(:wq)  
  (ex. pick aaaaaaa a.md -> drop aaaaaaa a.md)
  
  ※ 충돌 발생 시 해결 후 `git rebase --continue` 진행.

<br>

## 2. Remote에 반영해서 commits 삭제
Local과 remote의 history가 다르므로, `force` option을 사용.
```
git push origin HEAD --force
```

<hr>

## 참고
- **Git에서 원격 commits 삭제** - https://hackernoon.com/how-to-delete-commits-from-remote-in-git
