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
아래에 명시된 내용은 해당 작업을 진행하는데 사용한 구성이니 다른 옵션이나 자세한 사항은 Docs를 참고

- **S3 Bucket 및 directory, CodeDeploy Application, CodeDeploy Deployment Group**
  - **S3 Bucket 및 directory**  
    ![image](https://user-images.githubusercontent.com/46125158/197332343-f13d2d57-d8c8-4943-91c8-4fd2c1538b75.png)
  - **CodeDeploy Application**  
    ![image](https://user-images.githubusercontent.com/46125158/197332361-0e62b93e-f947-48df-af35-d4abb56110e2.png)
  - **CodeDeploy Deployment Group**  
    ![image](https://user-images.githubusercontent.com/46125158/197332428-5fc43fd4-67ff-4c34-90aa-43d18c6c0c28.png)
  - 각 이름은 .gitlab-ci.yml에서 변수로 사용
    - ```yaml
      variables:
        S3_BUCKET: bigmtn1113-s3-cd-revisions
        S3_BUCKET_DIR: java-test
        CODEDEPLOY_APPLICATION: bigmtn1113-cd-application
        CODEDEPLOY_GROUP: bigmtn1113-cd-group
      ```
- **Auto Scaling Group이 사용할 Launch Template**
  - EC2(WEB)에 **CodeDeploy Agent**와 **Java** 설치 후 AMI를 생성하고 이 AMI로 Launch Template 생성  
    ![image](https://user-images.githubusercontent.com/46125158/197333004-4014411b-c1b0-4be2-8db5-569713eb3f6c.png)  
    ![image](https://user-images.githubusercontent.com/46125158/197333029-6561ea82-d16c-4cc4-bf0e-510ca3845a08.png)
- **EC2(WEB)에서 사용할 web server port는 8080**
  - **Target Group**에서 인스턴스의 **Health status** 확인
  - **Security Group**이 정상적으로 8080번 포트를 Open하고 있는지 확인
  - Application이 8080번 포트를 정상적으로 사용하고 있는지 확인
    ```bash
    netstat -nlp
    ps -ef | grep java
    curl localhost:8080
    ```
  
<hr>

## IAM
### IAM Role
- **CodeDeploy에 대한 서비스 역할**
  - EC2/온프레미스 배포의 경우 AWSCodeDeployRole 정책 연결
  - 시작 템플릿으로 Auto Scaling 그룹을 생성한 경우 다음 권한을 추가
    - ec2:RunInstances
    - ec2:CreateTags
    - iam:PassRole
  
  ![image](https://user-images.githubusercontent.com/46125158/197331865-70bf5abe-116a-4df4-a035-b19292825627.png)
- **EC2(WEB)에 대한 IAM 인스턴스 프로파일**
  - 애플리케이션이 저장되는 Amazon S3 버킷에 액세스할 수 있는 권한이 필요
    - s3:Get*
    - s3:List*
    - Resource는 Amazon S3 버킷 arn
  
  ![image](https://user-images.githubusercontent.com/46125158/197331949-b79720aa-2249-4b03-9509-f826b8fe17ae.png)
- **EC2(GitLab Runner)에 대한 IAM 인스턴스 프로파일에 AWSCodeDeployDeployerAccess 정책 추가**
  - GitLab Runner에서 CodeDeploy 배포를 생성하기 위한 접근 권한
  
  ![image](https://user-images.githubusercontent.com/46125158/197331999-76230f70-6eec-459c-b6e9-c0eb89e536d6.png)

<br>

## AWS CodeDeploy
### ※ Lifecycle 이벤트 hooks 이해
![image](https://user-images.githubusercontent.com/46125158/197333183-1150c7f0-deee-4b6d-b9cb-9e046a5899a5.png)

- **ApplicationStop**
  - application revision이 다운로드되기 전에도 발생
  - application을 안전하게 종료하거나 배포 준비 중에 현재 설치된 패키지를 제거하도록 스크립트 지정
  - AppSpec 파일은 인스턴스에 배포하기 전에는 인스턴스에 존재하지 않으므로 인스턴스에 처음으로 배포할 때는 ApplicationStop 후크가 실행되지 않음
  - 인스턴스에 두 번째로 배포할 때 ApplicationStop 후크 사용 가능
- **DownloadBundle**
  - 애플리케이션 수정 파일을 임시 위치인 `/opt/codedeploy-agent/deployment-root/deployment-group-id/deployment-id/deployment-archive`폴더로 복사
  - CodeDeploy 에이전트에 예약되어 있으므로 스크립트 실행에 사용 불가
- **BeforeInstall**
  - 파일 암호화 해제 및 현재 버전의 백업 만들기와 같은 사전 설치 작업에 사용 가능
- **Install**
  - revision 파일을 임시 위치에서 최종 대상 폴더(files의 destination에 명시한 경로)로 복사
  - CodeDeploy 에이전트에 예약되어 있으므로 스크립트 실행에 사용 불가
- **AfterInstall**
  - 애플리케이션 구성 또는 파일 권한 변경과 같은 작업에 사용 가능
- **ApplicationStart**
  - 일반적으로 'ApplicationStop'에서 중지한 서비스를 다시 시작할 때 사용
- **ValidateService**
  - 마지막 배포 수명 주기 이벤트
  - 배포가 성공적으로 완료되었는지 확인하는 데 사용

<hr>

## 참고
- **EC2/온프레미스 컴퓨팅 플랫폼의 배포** - https://docs.aws.amazon.com/ko_kr/codedeploy/latest/userguide/deployment-steps-server.html
- **CodeDeploy에 대한 서비스 역할 생성** - https://docs.aws.amazon.com/ko_kr/codedeploy/latest/userguide/getting-started-create-service-role.html
- **Amazon EC2 인스턴스에 대한 IAM 인스턴스 프로파일 만들기** - https://docs.aws.amazon.com/ko_kr/codedeploy/latest/userguide/getting-started-create-iam-instance-profile.html
- **AppSpec 'hooks' 섹션** - https://docs.aws.amazon.com/ko_kr/codedeploy/latest/userguide/reference-appspec-file-structure-hooks.html#appspec-hooks-server
