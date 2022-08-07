# LF will be replaced by CRLF or CRLF will be replaced by LF.md

<br>

## 원인
### OS마다 줄바꿈을 처리하는 방법 차이 존재
- **Unix** - 파일의 줄 바꿈에 **LF(Line Feed)** 사용
- **Windows** - 파일의 줄 바꿈에 **CRLF(Carriage Return + Line Feed)** 사용

어느 쪽을 선택해야 하는지에 대한 혼란 발생

### Error
- **Unix** - warning: CRLF will be replaced by LF
- **Windows** - warning: LF will be replaced by CRLF

<hr>

## 해결
### core.autocrlf 설정
```shell
# Windows
git config --global core.autocrlf true

# Unix
# CRLF를 LF로 변환하는 것은 허용하되, LF를 CRLF로 변환하는 것은 불허
git config --global core.autocrlf input
```
※ 특정 프로젝트에만 적용하고 싶다면 --global 옵션 생략

<hr>

## 참고
- **Customizing Git - Git Configuration** - https://git-scm.com/book/en/v2/Customizing-Git-Git-Configuration#Formatting-and-Whitespace
