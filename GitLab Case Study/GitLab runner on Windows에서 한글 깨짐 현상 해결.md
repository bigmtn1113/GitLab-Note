# GitLab runner on Windows에서 한글 깨짐 현상 해결

<br>

## 구성 환경
Windows PC에 GitLab runner 설치 및 등록(powershell)

<br>

## Error 재현
### 영어 및 한글 출력 test  
영어는 정상 출력되나 한글은 깨짐 현상 발생

![image](https://user-images.githubusercontent.com/46125158/233305540-d2e3ad3f-273c-4a75-98aa-c22300eeac57.png)

<br>

## 해결 방법
### GitLab runner를 작동시키고 있는 Windows server의 encoding 설정 수정
1. Powershell 에서 `intl.cpl` 실행
2. **국가 또는 지역 > 관리자 옵션 > 유니코드를 지원하지 않는 프로그램용 용어 > 시스템 로캘 변경** 선택
3. **Beta: 세계 언어 지원을 위해 Unicode UTF-8 사용** 체크 후, 확인

![image](https://user-images.githubusercontent.com/46125158/233305665-d665c795-4a88-49b1-9223-cb50a7acc241.png)

<br>

## 결과 화면
### 영어 및 한글 출력 test
모두 정상 출력

![image](https://user-images.githubusercontent.com/46125158/233305758-7e7333c8-91ec-40dc-af70-fc004f06e9a7.png)

<hr>

## 참고
- **GitLab: Runner (Windows)** - http://wiki.webperfect.ch/index.php?title=GitLab:_Runner_(Windows)
