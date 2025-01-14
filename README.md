# 알람 앱 프로젝트

## 1. 프로젝트 개요

### 프로젝트 정보
- **제목**: 알람 앱 (가칭 - 추후 수정 필요)
- **목적**: 알람 앱 개발
- **프로젝트 기간**: 01/07 (화) 11:00 ~ 01/15 (수) 12:00
- **깃헙 Repository**: [AlarmApp](https://github.com/ISFJ-s-Alarm/AlarmApp)

### 설계 문서
- **와이어프레임**: [Figma 링크](https://www.figma.com/design/OMEy7sY8s9g3ToTHAPQIrK/%EC%99%80%EC%9D%B4%EC%96%B4-%ED%94%84%EB%A0%88%EC%9E%84?node-id=0-1&p=f&t=QI9TRT7o6TrtIsZV-0)

## 2. 개발 구현 사항

### 필수 구현 기능
1. **알람 기능**
   - [X] 알람을 추가할 수 있고 알람 스위치를 통해 on/off 동작
   - [X] 알람 설명, 반복 여부 등 알람에 필요한 정보를 입력
   - [X] 해당 시각이 되면 알람 사운드가 재생

2. **스톱워치 기능**
   - [X] 0초부터 시작하는 스톱워치를 구현
   - [X] "멈춤" 버튼을 누르면 스톱워치가 멈추도록 구현

3. **타이머 기능**
   - [X] 유저가 시간을 설정할 수 있도록 구현
   - [X] 시간이 0초가 되면 사운드가 재생

4. **사용자 친화적인 인터페이스**
   - [X] 직관적이고 시각적으로 매력적인 사용자 인터페이스를 구현
   - [X] 기본 알람 앱을 참고

### 도전 구현 사항
1. **타이머 UI 개선**
   - [X] 아이폰 기본 알람 앱처럼 시간이 줄어들면서 시간을 나타내는 UI 구현

2. **세계 시계 기능**
   - [ ] 아이폰 기본 알람 앱처럼 세계 시계를 추가하고 편집할 수 있도록 구현

3. **애니메이션**
   - [ ] 미묘한 애니메이션이나 전환을 추가하여 사용자 경험을 향상

4. **디자인 패턴**
   - [X] MVVM 패턴 적용

## 3. 역할 분담

- **유태호**: 타이머, 음악 컨트롤러
- **이재건**: 알람 메인 화면
- **서현욱**: 하단 탭바, 스톱워치
- **오푸른솔**: 알람 화면
- **서지민**: 알람 모달

**공통 업무**
- SA 작성
- 스크럼 일지 정리
- QnA 정리
- 시연 영상
- 발표 자료
- ReadMe 작성

## 4. 협업 약속

### 일정 관리
- **점심시간**: 12:00~13:30
- **저녁시간**: 18:30~20:00
- **스크럼**: 17:00 (개발업무 공유 및 알게된 것, 알려주고 싶은 것 공유)

### 커뮤니케이션
- 외출/부재 시 팀원, 매니저님께 알리고 일정 공유
- 트러블, 이슈공유는 즉각 알림
- Merge 시 팀원 전체 코드리뷰 작성

## 5. Git 컨벤션

### 커밋 메시지 구조
```
type: subject

body

footer
```

### 커밋 타입
- `feat`: 새로운 기능 추가
- `fix`: 버그 수정
- `docs`: 문서 수정
- `style`: 코드 포맷팅, 세미콜론 누락, 코드 변경이 없는 경우
- `refactor`: 코드 리펙토링
- `test`: 테스트 코드, 리펙토링 테스트 코드 추가
- `chore`: 빌드 업무 수정, 패키지 매니저 수정
- `cmt`: 주석수정

### 커밋 메시지 규칙
1. Subject
   - 최대 50글자
   - 마침표 및 특수기호 사용하지 않음
   - 동사 원형으로 시작하고 첫 글자는 대문자로 표기

2. Body
   - 한 줄당 72자 내로 작성
   - 변경한 내용과 이유를 상세히 작성

3. Footer
   - Optional
   - 이슈 트래커 ID 작성
   - "유형: #이슈 번호" 형식 사용

### 커밋 예시
```
Feat: "회원 가입 기능 구현"

SMS, 이메일 중복확인 API 개발

Resolves: #123
Ref: #456
Related to: #48, #45
```

## 6. 브랜치 전략

### 브랜치 규칙
- 3명의 `approve` 필요
- `main`: 배포용 브랜치
- `develop`: 개발 중인 브랜치
- `feature/기능명`: 기능 개발 브랜치
  - kebab-case 사용
  - 예시: feature/movie-list

### 브랜치 구조
```
main
└── develop
    ├── feature/alarm/MainView     # 이재건
    ├── feature/alarm/stopwatch    # 서현욱
    ├── feature/TimerView      # 유태호
    ├── feature/alarm-alert        # 오푸른솔
    └── feature/alarm/editor       # 서지민
```
## 🎵 음원 출처
- 추가한 음악 파일들은 넥슨게임의 BGM임
- 넥슨은 금전적 활동이 아니라면 인게임내 BGM들 전부 무료소스로 풀고있어서 저작권 문제는 안걸림

- 해당 항목출처
[넥슨IP사용가이드](https://member.nexon.com/policy/gameipguide.aspx)

- 사용된 음악: 메이플스토리 게임내 BGM
  - Adele's Oath
    - https://www.youtube.com/watch?v=PEydgwUIHiM
    
  - Life is Full of Happiness
    - https://www.youtube.com/watch?v=oGJywoKIIlc
    
  - Raindrop Flower
    - https://www.youtube.com/watch?v=kizi98UD5ak
    
  - Riding on the Clouds
    - https://www.youtube.com/watch?v=6pV7GPXgfCg
    
  - Romantic Sunset
    - https://www.youtube.com/watch?v=jeBaOmKBpjQ
    
  - When the Morning Comes
    - https://www.youtube.com/watch?v=yGHAy4jUSbE
