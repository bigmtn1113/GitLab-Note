# Instance template repository

<br>

Hosted systems에서 기업들은 teams 간에 자체 templates을 공유해야 하는 경우가 많음.  
이 기능을 사용하면 관리자는 file templates의 instance-wide collection이 될 project 선택 가능.  
이러한 templates는 proejct가 안전하게 유지되는 동안 Web Editor를 통해 모든 사용자에게 노출됨.

<br>

## 구성
1. 왼쪽 sidebar에서 **Search or go to** 선택.
2. **Admin Area** 선택.
3. **Settings > Templates** 선택.
4. **Templates** 확장.
5. Dropdown 목록에서 template repository로 사용할 project 선택.
6. **Save changes** 선택.
7. 선택한 repository에 사용자 정의 templates 추가.

![image](https://github.com/bigmtn1113/GitLab-Note/assets/46125158/963a4248-bf86-46e3-8219-2569e6f4e098)

Templates를 추가한 후에는 전체 instance에서 사용 가능.  
Web Editor와 API settings를 통해 사용 가능.

이러한 templates는 `.gitlab-ci.yml`의 `include:template` key 값으로 사용 불가.

<br>

## 지원되는 file 형식 및 위치
Template 종류에 따라 repository의 특정 하위 directory에 templates 추가 필요.  
다음 유형의 사용자 정의 templates 지원:  
Type | Directory | Extension
:---: | :---: | :---:
Dockerfile | Dockerfile | .dockerfile
.gitignore | gitignore | .gitignore
.gitlab-ci.yml | gitlab-ci | .yml
LICENSE | LICENSE | .txt

각 template은 해당 하위 directory에 있어야 하며, 올바른 확장자를 갖고 비어 있으면 안 됨.  
따라서 계층 구조는 다음과 같이 구성:  
```
|-- README.md
|-- Dockerfile
    |-- custom_dockerfile.dockerfile
    |-- another_dockerfile.dockerfile
|-- gitignore
    |-- custom_gitignore.gitignore
    |-- another_gitignore.gitignore
|-- gitlab-ci
    |-- custom_gitlab-ci.yml
    |-- another_gitlab-ci.yml
|-- LICENSE
    |-- custom_license.txt
    |-- another_license.txt
```

![image](https://github.com/bigmtn1113/GitLab-Note/assets/46125158/d47e1a5c-d221-4a37-83d8-b376cd0d7369)

GitLab UI를 통해 새 file이 추가되면 사용자 정의 templates가 dropdown 목록에 표시됨:  
![image](https://github.com/bigmtn1113/GitLab-Note/assets/46125158/a6fa672b-6e8b-46b6-87d7-5f5224d84b77)

<hr>

## 참고
- **Instance template repository** - https://docs.gitlab.com/ee/administration/settings/instance_template_repository.html
