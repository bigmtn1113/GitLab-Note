# GitLab과 AWS CodeDeploy를 사용한 AWS EC2 배포 방법 소개

<br>

## 시나리오
개발자들이 GitLab을 이용해 소스 코드를 수정하면 GitLab Runner가 '빌드 결과물이 담긴 Application revision 파일을 S3 Bucket에 업로드 하고 deployment를 생성'하는 내용이 적힌 .gitlab-ci.yml 파일을 실행하고 AWS CodeDeploy는 배포 그룹 및 배포 내용에 맞게 배포를 진행. 이때 AWS EC2에 설치된 CodeDeploy Agent는 S3 Bucket에 업로드 된 revision 파일을 복사하고 이 파일을 이용해 배포를 수행

<br>

## Architecture
![image](https://user-images.githubusercontent.com/46125158/194706856-97b697bb-cfa4-470b-9f90-342f781f600b.png)  
![image](https://user-images.githubusercontent.com/46125158/194710384-52237765-7b4c-4073-a241-8683dd6075b7.png)

<br>

## 사전 작업

- **내용**
- **내용**

<hr/>

## 내용

### 내용


<hr>

## 참고
- **EC2/온프레미스 컴퓨팅 플랫폼의 배포** - https://docs.aws.amazon.com/ko_kr/codedeploy/latest/userguide/deployment-steps-server.html
- **CodeDeploy에 대한 서비스 역할 생성** - https://docs.aws.amazon.com/ko_kr/codedeploy/latest/userguide/getting-started-create-service-role.html
- **Amazon EC2 인스턴스에 대한 IAM 인스턴스 프로파일 만들기** - https://docs.aws.amazon.com/ko_kr/codedeploy/latest/userguide/getting-started-create-iam-instance-profile.html
- **AppSpec 'hooks' 섹션** - https://docs.aws.amazon.com/ko_kr/codedeploy/latest/userguide/reference-appspec-file-structure-hooks.html#appspec-hooks-server
