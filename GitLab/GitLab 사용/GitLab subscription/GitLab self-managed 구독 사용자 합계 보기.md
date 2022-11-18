# GitLab self-managed 구독 사용자 합계 보기

<br>

## 사용자 합계 보기
라이선스에 대한 사용자를 보고 구독 기간을 넘겼는지 확인 가능

1. 상단 표시줄에서 **Main menu > Admin** 선택
2. 왼쪽 메뉴에서 **Subscription** 선택

### Users in License
시스템에 로드된 현재 라이선스에서 비용을 지불한 사용자 수. 현재 구독 기간 동안 시트를 추가하지 않는 한 숫자는 변경되지 않음

### Billable users
시스템에서 청구 가능한 일일 사용자 수. 인스턴스에 사용자를 차단, 비활성화 또는 추가하면 개수가 변경될 수 있고 청구 가능한 사용자는 구독 시트 수에 포함. 다음을 제외하고 모든 사용자는 청구 대상 사용자로 간주

- Deactived 사용자 및 blocked 사용자
- 승인 대기 중인 사용자
- Ultimate 구독에서 게스트 역할을 가진 구성원
- Ultimate 구독에 대한 프로젝트 또는 그룹 멤버십이 없는 사용자
- GitLab에서 생성한 서비스 계정
  - Ghost User: contributions를 남긴 채 user만 삭제한 경우
  - 다음과 같은 Bots
      - Support Bot, Support Bot, Ghost User
      - 프로젝트용 Bot users: project access token을 생성하면 생성되는 Bot
      - 그룹용 Bot users: group access token을 생성하면 생성되는 Bot

Admin 섹션에 보고된 **Billable users**는 하루에 한 번 업데이트

### Maximum users
현재 라이선스 기간 동안 청구 가능한 최대 사용자 수(인스턴스에 기록된 최대 일일 활성 사용자 수)를 반영

### Users over license
라이선스를 초과한 사용자 수는 라이선스에서 허용한 수를 초과한 사용자 수를 표시. 이 숫자는 현재 라이센스 기간을 반영

예를 들어 다음과 같은 경우:
- 라이센스는 100명의 사용자를 허용하고 **Maximum users**는 150명이면 이 값은 50

**Maximum users** 값이 100보다 작거나 같으면 이 값은 0  
평가판 라이선스는 **Users over license**에 대해 항상 0을 표시

라이선스가 부여된 것보다 더 많은 사용자를 GitLab 인스턴스에 추가하는 경우 갱신 시점에 추가 사용자에 대한 요금을 지불해야 하고 갱신 프로세스 중에 추가 사용자에 대한 요금을 지불하지 않으면 라이선스 키가 작동하지 않는 점 주의

<hr>

## 참고
- ****GitLab self-managed subscription**** - [https://docs.gitlab.com/ee/subscriptions/self_managed/](https://docs.gitlab.com/ee/subscriptions/self_managed/)
