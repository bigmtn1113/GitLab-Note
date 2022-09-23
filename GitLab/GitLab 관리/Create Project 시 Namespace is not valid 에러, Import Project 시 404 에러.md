# Create Project 시 Namespace is not valid 에러, Import Project 시 404 에러

<br>

## 에러 발생

![image](https://user-images.githubusercontent.com/46125158/191914385-b7a14b3d-665d-49c7-a49f-18df3d00ffd8.png)
![image](https://user-images.githubusercontent.com/46125158/191914594-2af1e5d7-8cf6-4cad-8b9f-b1c2b2364e83.png)

<br>

## 원인
기본 프로젝트 제한을 0으로 설정하면 사용자는 자신의 개인 네임스페이스에서 프로젝트 생성 불가.  
그러나 프로젝트는 여전히 그룹에서 생성 가능

※ 특정 사용자에게만 이슈가 발생된다면 **사용자에 대한 프로젝트 제한** 설정 진행

<br>

## 해결
### 기본 프로젝트 제한
1. Admin 계정 로그인
2. **Menu > Admin** 선택
3. **Settings > General** 선택 후, **Account and limit** 섹션 확장
4. **Default projects limit** 값 변경

### 사용자에 대한 프로젝트 제한
1. Admin 계정 로그인
2. **Menu > Admin** 선택
3. **Overview > Users** 선택
4. **User** 선택
5. **Edit** 선택
6. **Projects limit** 값 변경

Projects limit 값이 0으로 설정 되어 있다면 해당 값을 1 이상의 값으로 설정(기본값은 20).

<hr>

## 참고
- **기본 프로젝트 제한** - https://docs.gitlab.com/ee/user/admin_area/settings/account_and_limit_settings.html#default-projects-limit
