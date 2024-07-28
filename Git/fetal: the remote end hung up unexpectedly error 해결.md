# fetal: the remote end hung up unexpectedly error 해결

<br>

크기가 Git configuration에 설정된 수치(기본값: 1MB)보다 큰 file이 존재할 경우, `git clone` 또는 `git push` 등의 상황에서 발생하는 error.

<br>

## git config 설정
최대 크기 file의 용량 확인 후 진행.

1. `http.postBuffer` 값 변경.

   단일 file 크기가 1G인 경우에도 허용할 수 있도록 POST buffer size를 1GiB로 증설:
   ```
   # 1GiB
   git config --global http.postBuffer 1048576000
   ```

2. 변경 내용 확인:

   ```
   cat ~/.gitconfig
   ```

   `.gitconfig` file이 다음과 같이 잘 적용되었는지 확인.
   ```
   [http]
           postBuffer = 1048576000
   ```

3. `git clone` 또는 `git push` 재시도.
