# git config

## system
### /etc/gifconfig
파일 시스템의 모든 사용자와 모든 저장소에 적용되는 설정  
시스템 전체 설정 파일이므로 수정하려면 시스템의 관리자 권한 필요  
```shell
git config --system
```

<hr>

## global
### ~/.gitconfig, ~/.config/git/config
현재 사용자에게만 적용되는 설정   
특정 사용자의 모든 저장소 설정에 적용  
```shell
git config --global
```

<hr>

## local
### .git/config
특정 저장소에만 적용  
기본적으로 이 옵션이 사용되나, 이 옵션을 적용하려면 Git 저장소인 디렉터리로 이동한 후 적용 가능  
```shell
git config --local
```

<hr>

## 적용 우선순위
**local → global → system**

<hr>

## 참고
- **Git 최초 설정** - https://git-scm.com/book/ko/v2/%EC%8B%9C%EC%9E%91%ED%95%98%EA%B8%B0-Git-%EC%B5%9C%EC%B4%88-%EC%84%A4%EC%A0%95
