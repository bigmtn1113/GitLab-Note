# GitHub commit 시, contributions(잔디) 문제

## 원인
### 사용자 정보 불일치
![image](https://user-images.githubusercontent.com/46125158/181903026-869211e0-3378-4e68-b2ba-0cb8033ef52f.png)  
GitHub 계정은 kva231인데, 사용자는 bigmtn이므로 contributions(잔디)에 기록되지 않음  
※ bigmtn는 `git config --global`로 설정된 사용자였고 `git config --local`로 설정된 사용자는 없어서 global 사용자로 commit됨

<hr>

## 해결
### git config 설정
![Cap 2022-07-30 17-54-13-307](https://user-images.githubusercontent.com/46125158/181903197-8b64e739-c841-422a-a43b-aac868beb4a9.png)  
다음과 같은 명령어를 통해 GitHub 계정과 사용자 정보를 일치시키면 정상적으로 기록됨
```shell
git config --local user.name "kva231"
git config --local user.email "kva231@naver.com"
```
※ `git config --global` 명령어로 global로 설정된 bigmtn 정보를 kva231로 바꾸어도 됨

<hr>

## 참고
- **git config** - https://github.com/kva231/GitLab-Note/blob/master/Git/git%20config.md
