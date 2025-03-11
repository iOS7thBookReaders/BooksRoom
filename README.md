<div align="center">

![Image](https://github.com/user-attachments/assets/37b3a5a6-9626-4399-93af-901cb56ce0ed)

# 책방
<br/> [<img src="https://img.shields.io/badge/프로젝트 기간-2025.03.06~2025.03.10-fab2ac?style=flat&logo=&logoColor=white" />]()

</div> 

## 📝 소개

❮책방❯은 독서기록을 저장하는 공간입니다.
원하는 책을 북마크 할 수 있으며, 리뷰를 저장할 수 있습니다.
<br />

### 📷 스크린샷
| 로그인 | 회원가입 |
|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/b158e2d8-aec1-4794-942f-ffdeca2ab505" width="200" height="400"/> | <img src="https://github.com/user-attachments/assets/5e4cde38-06ee-4760-abe1-a3d5e90f9a44" width="200" height="400"/> |

| 베스트셀러 | 읽는중인 책 | 찜한 책 |
|:---:|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/249505ac-9b11-454a-96bb-5b8a34d681e9" width="200" height="400"/>  | <img src="https://github.com/user-attachments/assets/89170078-c9b9-4091-b88d-f57022302faf" width="200" height="400"/> | <img src="https://github.com/user-attachments/assets/bc37d9f1-339e-42ff-830f-c09476540cef" width="200" height="400"/> |

| 검색 - 조건 | 조건 + 정렬 | 책 상세보기 |
|:---:|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/21f46fc3-f1f1-4966-9fa4-8462980e2c73" width="200" height="400"/>) | <img src="https://github.com/user-attachments/assets/d2f168c4-e8c0-417d-ba18-65f77252b605" width="200" height="400"/> | <img src="https://github.com/user-attachments/assets/a9cc15c5-5145-451d-977c-864c3203458f" width="200" height="400"/> |

| 리뷰작성 | 리뷰수정 | 리뷰보기 |
|:---:|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/61a889ce-5a25-4fea-befc-526c2a690f33" width="200" height="400"/> | <img src="https://github.com/user-attachments/assets/68f9a4fc-7d48-4ded-a498-2d104877bc95" width="200" height="400"/> | <img src="https://github.com/user-attachments/assets/dcd89986-9027-4f3f-a116-cc13c31c91a7" width="200" height="400"/> |

| 책 상세정보 | 캘린더 | 마이페이지 |
|:---:|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/99ed95cc-4bd7-46bc-985a-51d2d9969069" width="200" height="400"/> | <img src="https://github.com/user-attachments/assets/4f46f086-70c5-4266-9a43-90e94e179b4d" width="200" height="400"/> | <img src="https://github.com/user-attachments/assets/3fe04a8f-6b44-48ad-9b20-ad2e37148575" width="200" height="400"/> |


<br />



### 🔧 세부 기능
- 베스트셀러 목록
  -  알라딘 상품 리스트 API를 이용하여 베스트셀러 목록을 보이도록 하였습니다.
- 읽는중인 책 목록
  - FireStore에 저장되어있는 isReading 상태의 책들의 목록을 확인할 수 있습니다.
- 찜 목록
  - FireStore에 저장되어있는 isWishing 상태의 찜 한 책들의 목록을 확인할 수 있습니다.
- 검색기능
  - 알라딘 상품 검색 API를 이용하여 [키워드, 제목, 저자, 출판사]의 쿼리로 검색할 수 있습니다.
- 책 상세보기
  - 알라딘 상품 조회 API를 이용하여 제목, 발행연도, 저자, 쪽수, 표지 등을 상세하게 표시하였습니다.
  - 본인이 준 별점 리뷰를 한눈에 볼 수 있도록 설정하였습니다.
  - 찜 상태, 읽는 중 상태를 변경할 수 있습니다.
  
- 읽은 책 리뷰작성하기
  - 다 읽은 날짜, 리뷰내용, 한줄평가, 별점을 줄 수 있습니다.
- 캘린더
  - 본인이 작성한 날짜별 리뷰를 볼 수 있습니다.
- 마이페이지
  - 본인 정보를 확인할 수 있습니다.
  - 작성한 리뷰, 읽는 중인 책, 찜한 책의 갯수를 볼 수 있습니다.
  - 본인이 작성한 리뷰를 관리할 수 있습니다.



### 👀 회고
  
##### 👍 배운것
    ✓ provider 상태관리
    ✓ pagination에 대한 이해
    ✓ Git 브랜치 관리
    ✓ Firebase
    ✓ 캐시데이터

##### 🥲 아쉬운점
    ✓ pagination 리로드 문제
    ✓ 빌드 과정에서의 문제(속도 등..)
    ✓ 알라딘의 불안정한 서버 -> 캐시데이터 공부하는데 오히려 도움되었음
    ✓ 디자인은 어렵다........

<br />

## 💁‍♂️ 프로젝트 팀원
##### 강보현 [@Bhynnnn](https://github.com/Bhynnnn)
- 홈
- 검색
- 책 상세보기
- 캘린더
- 마이페이지
- API 관련 로직
  
##### 고지용 [@Jiyoun-ko](https://github.com/Jiyong-ko)
- 로그인/회원가입
- 리뷰 CRUD
- 홈
- 캐시데이터
- Firebase 관련 로직
