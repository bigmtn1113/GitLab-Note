# Repository의 일부분 clone

<br>

Git remote repository를 clone하려고 할 때, 필요한 부분만 clone 가능.  
혹은 network 상태가 불안정하거나 repository 용량이 너무 클 경우에도 이용 가능.

오류 예시:

```
error: RPC failed; curl 18 transfer closed with outstanding read data remaining
error: 6372 bytes of body are still expected
fetch-pack: unexpected disconnect while reading sideband packet
fatal: early EOF
fatal: fetch-pack: invalid index-pack output
```

<br>

## 단일 branch를 clone한 상태에서 전체 clone
1. 단일 branch를 clone 및 가장 최근 commit history 개수만큼 clone:

   ```
   git clone --branch <branch-name> --depth <number-of-commits> <remote-url>
   ```

2. Repository 이동:

   ```
   cd <repository-name>
   ```

3. Remote branch 및 commit history 확인:

   ```
   git branch -a
   git log
   ```

4. 모든 branches clone을 위해 remote 설정 변경:

   - Case 1:

     ```
     git remote set-branches origin '*'
     ```

   - Case 2:

     ```
     git config remote.origin.fetch
     # +refs/heads/<branch-name>:refs/remotes/origin/<branch-name>

     git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
     ```

   - Case 3:

     `.git/config`에서 `fetch = +refs/heads/<branch-name>:refs/remotes/origin/<branch-name>` 부분을 `fetch = +refs/heads/*:refs/remotes/origin/*`로 수정.

5. 변경한 remote 설정 update 후 remote branch 확인:

   ```
   git remote update
   git branch -a
   ```

6. 현재 branch의 나머지 commit history clone:

   ```
   git fetch --unshallow
   ```

<hr>

## 참고
- **Git shallow clone에서 전체 clone하는 방법** - https://stackoverflow.com/questions/6802145/how-to-convert-a-git-shallow-clone-to-a-full-clone
- **단일 브랜치만 복제한 후 Git에서 모든 원격 브랜치를 가져오는 방법** - https://www.delenamalan.co.za/2019/fetch-all-branches.html
