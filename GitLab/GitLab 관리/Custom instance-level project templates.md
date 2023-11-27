# Custom instance-level project templates

<br>

관리자는 instance에서 project templates의 source로 사용할 수 있는 project가 포함된 group 구성 가능.  
그런 다음 template project의 contents에서 시작하는 새 project 생성 가능.

<br>

## Template projects를 관리할 group 선택
Instance에서 template projects를 사용할 수 있도록 하기 전에 templates를 관리할 group을 선택.  
Templates가 예기치 않게 변경되는 것을 방지하려면 기존 group을 재사용하는 대신, 이 목적을 위한 새 group을 생성.  
개발 작업에 이미 사용 중인 기존 group을 재사용하는 경우 Maintainer 역할을 가진 users는 부작용을 이해하지 못한 채 template projects를 수정할 가능성 존재.

1. 왼쪽 sidebar에서 **Search or go to** 선택.
2. **Admin Area** 선택.
3. 왼쪽 sidebar에서 **Settings > Templates** 선택.
4. **Custom project templates** 확장.
5. 사용할 group 선택.
6. **Save changes** 선택.

![image](https://github.com/bigmtn1113/GitLab-Note/assets/46125158/b713c8c3-c8e9-49e5-9c3d-9305f8e4fbdf)

Group이 project templates의 source로 구성되면 이후에 이 group에 추가된 모든 새 projects를 templates로 사용 가능.  
![image](https://github.com/bigmtn1113/GitLab-Note/assets/46125158/10903b74-608f-459f-b108-36f21f407d9a)

<br>

## Template으로 사용할 project 구성
Instance의 templates를 관리하기 위한 group을 생성한 후 각 template project의 visibility and feature availability 구성.

> [!IMPORTANT]  
> Instance의 관리자이거나 project를 구성할 수 있는 역할을 가진 users만 작업 가능.

1. Project가 하위 group을 통하지 않고 group에 직접 속해 있는지 확인.  
  선택한 group의 하위 groups에 속한 projects는 templates로 사용 불가능.
2. Project template을 선택할 수 있는 users를 구성하려면 project의 visibility를 설정:
   - 인증된 user는 **Public** 및 **Internal** projects 선택 가능.
   - **Private** projects는 해당 project의 members만 선택 가능.
3. Project의 feature settings를 검토.  
  활성화된 모든 project features는 **GitLab Pages** 및 **Security and Compliance**를 제외하고 **Everone With Access**로 설정되어야 함.

각각의 새 project에 복사되는 repository 및 database 정보는 GitLab Project Import/Export로 내보낸 data와 동일.

<hr>

## 참고
- **Custom instance-level project templates** - https://docs.gitlab.com/ee/administration/custom_project_templates.html
