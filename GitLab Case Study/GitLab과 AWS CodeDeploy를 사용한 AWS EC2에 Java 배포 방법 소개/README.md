# GitLab과 AWS CodeDeploy를 사용한 AWS EC2에 Java 배포 방법 소개

<br>

## 시나리오
개발자들이 GitLab을 이용해 소스 코드를 수정하면 GitLab Runner가 '빌드 결과물이 담긴 Application revision 파일을 S3 Bucket에 업로드 하고 deployment를 생성'하는 내용이 적힌 .gitlab-ci.yml 파일을 실행하고 AWS CodeDeploy는 배포 그룹 및 배포 내용에 맞게 배포를 진행. 이때 AWS EC2에 설치된 CodeDeploy Agent는 S3 Bucket에 업로드 된 revision 파일을 복사하고 이 파일을 이용해 배포를 수행

<br>

## Architecture
![image](https://user-images.githubusercontent.com/46125158/194706856-97b697bb-cfa4-470b-9f90-342f781f600b.png)  
![image](https://user-images.githubusercontent.com/46125158/194710384-52237765-7b4c-4073-a241-8683dd6075b7.png)

<br>

## 유의 사항
- **S3 Bucket 및 directory, CodeDeploy Application, CodeDeploy Deployment Group**
  - 각 이름은 .gitlab-ci.yml에서 변수로 사용
  - CodeDeploy Deployment Group에서 배포 유형은 Blue/Green
- **Auto Scaling Group이 사용할 Launch Template**
  - EC2(WEB)에 CodeDeploy Agent와 Java 설치 후 AMI를 생성하고 이 AMI로 Launch Template 생성
- **CodeDeploy에 대한 서비스 역할**
  - EC2/온프레미스 배포의 경우 AWSCodeDeployRole 정책 연결
  - 시작 템플릿으로 Auto Scaling 그룹을 생성한 경우 다음 권한을 추가
    - ec2:RunInstances
    - ec2:CreateTags
    - iam:PassRole
- **EC2(WEB)에 대한 IAM 인스턴스 프로파일**
  - 애플리케이션이 저장되는 Amazon S3 버킷에 액세스할 수 있는 권한이 필요
    - s3:Get*
    - s3:List*
    - Resource는 Amazon S3 버킷 arn
- **EC2(GitLab Runner)와 연결된 IAM Role에 AWSCodeDeployDeployerAccess 정책 추가**
- **EC2(WEB)에서 사용할 web server port는 8080**

<hr>

## 참고
- **EC2/온프레미스 컴퓨팅 플랫폼의 배포** - https://docs.aws.amazon.com/ko_kr/codedeploy/latest/userguide/deployment-steps-server.html
- **CodeDeploy에 대한 서비스 역할 생성** - https://docs.aws.amazon.com/ko_kr/codedeploy/latest/userguide/getting-started-create-service-role.html
- **Amazon EC2 인스턴스에 대한 IAM 인스턴스 프로파일 만들기** - https://docs.aws.amazon.com/ko_kr/codedeploy/latest/userguide/getting-started-create-iam-instance-profile.html
- **AppSpec 'hooks' 섹션** - https://docs.aws.amazon.com/ko_kr/codedeploy/latest/userguide/reference-appspec-file-structure-hooks.html#appspec-hooks-server
