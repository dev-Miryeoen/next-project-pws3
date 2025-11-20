# 🔐 next-project-pws3  
Password Simple Storage Service (Local Password Manager)  
Next.js + MySQL 기반 로컬 비밀번호 관리 서비스

---

## 📌 프로젝트 소개
**next-project-pws3**는 사용자가 사용하는 다양한 웹사이트의  
아이디/비밀번호 정보를 **안전하게 로컬에서** 저장하고 관리할 수 있는  
간단한 Password Manager 프로젝트입니다.

🔥 모든 데이터는 암호화(AES-256)되어 저장되며  
외부 서버로 전송되지 않습니다.

---

## 🗂 주요 기능
- 회원가입 / 로그인
- AES 암호화를 이용한 안전한 비밀번호 저장
- 비밀번호 리스트 조회
- 리스트 상세 정보 열람 (마스터 비밀번호 입력 후 복호화)
- 비밀번호 리스트 생성 / 수정 / 삭제 (CRUD)
- 사용처명, URL, 암호 저장

---

## 🛠 기술 스택
- **Next.js 14 (App Router)**
- **MySQL**
- TypeScript
- bcrypt (비밀번호 해시)
- crypto (AES-256 암호화)
- Tailwind CSS

---

## 📁 프로젝트 구조
next-project-pws3/
├─ app/
├─ db/
│ └─ schema.sql
├─ lib/
├─ .env.example
├─ README.md
└─ package.json


---

# 🚀 설치 및 실행 방법

## 1) 프로젝트 클론
```sh
git clone https://github.com/yourname/next-project-pws3.git
cd next-project-pws3


2) MySQL DB 생성

MySQL에 접속 후 아래 명령 실행:

SOURCE db/schema.sql;


그러면 아래 DB가 자동 생성됨:

Database: next_pws3

Tables: users, vault_items

3) .env 파일 생성

아래 명령 실행:

cp .env.example .env


그리고 자신의 환경에 맞게 수정:

DB_USER=root
DB_PASSWORD=yourpassword
ENCRYPTION_SECRET=32bytes_hex_key
JWT_SECRET=random_jwt_key

4) 패키지 설치
npm install

5) 개발 서버 실행
npm run dev

🔐 AES 암호화 관련 정보

모든 저장되는 비밀번호는 다음 방식으로 암호화됩니다:

알고리즘: AES-256-CBC

키: process.env.ENCRYPTION_SECRET

IV: 매 요청 시 랜덤 16바이트 생성 후 DB에 저장

DB가 유출되더라도 복호화 키를 모르면 절대 비밀번호를 볼 수 없습니다.