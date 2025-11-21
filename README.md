# 🔐 next-project-pws3
Local Password Manager — Next.js + MySQL 기반 안전한 비밀번호 관리 서비스

# 📌 프로젝트 소개
next-project-pws3는 Next.js와 MySQL 기반으로 제작된<br />
완전한 로컬 비밀번호 관리 프로그램(Local Password Manager) 입니다.

이 프로젝트는 웹사이트 비밀번호를 안전하게 저장하고,<br />
사용자가 입력한 마스터 비밀번호 기반 AES-256 암호화 구조로<br />
절대 평문 비밀번호가 서버에 저장되지 않도록 설계되었습니다.

# 🔥 핵심 특징
## ✔️ 1. 2중 보안 암호화 구조
### 🔑 1) 사용자 로그인 키 (Login Password, "로그인키")
bcrypt로 해시 저장 (users.password)<br />
서버가 알고 있는 유일한 비밀번호 관련 값<br />
로그인 인증만 담당<br />
암호화나 복호화에는 전혀 사용되지 않음

### 🔒 2) 사용자 마스터 키(User Master Password)
비밀번호 항목들을 암/복호화하는 "진짜 핵심 비밀"<br />
PBKDF2(master_password + master_salt) → dataKey 생성<br />
절대 서버에 저장되지 않음<br />
로그인 비밀번호와는 완전히 별도<br />
※ 마스터 비밀번호를 잃으면 dataKey를 파생할 수 없음 → 복구키 없이 복구 불가

### 🔒 3) dataKey (AES-256-GCM으로 항목 암/복호화하는 실제 키)
클라이언트에서만 생성됨 (PBKDF2)<br />
서버는 저장하지 않음<br />
복구를 위해 서버는 dataKey를 암호화된 형태로만 저장<br />
wrapped_data_key<br />
wrapped_data_key_iv

### 🔁 4) 복구키(Recovery Key)
무작위 256bit <br />
마스터 비밀번호 없이도 dataKey를 복구하는 유일한 수단<br />
wrapped_data_key를 복호화할 수 있는 키<br />
평문은 사용자에게 직접 제공하여 보관하도록 함<br />
서버에는 절대 평문 저장되지 않음

## ✔️ 2. 보안 강화된 세션 시스템
MySQL 기반 세션 저장소<br />
서버가 세션 유효시간을 직접 판단<br />
클라이언트는 1초 단위 UI 타이머 / 10초 단위 서버 동기화<br />
세션 만료 시 즉시 강제 로그아웃<br />
“연장하기” 버튼으로 5분 연장 가능

## ✔️ 3. 기능 구성
회원가입 / 로그인 / 로그아웃<br />
마스터키 + 복구키 기반 보안 시스템<br />
비밀번호 생성, 수정, 삭제 (CRUD)<br />
마스터 비밀번호 입력 시 복호화 기능<br />
비밀번호 보기 시 10초 자동 삭제 표시(SecurePasswordView)<br />
Dark Mode 지원<br />
컴포넌트 기반 분리 (유지보수성 향상)

# 🗂 프로젝트 구조
```
next-project-pws3/
├─ app/
│  ├─ login/
│  ├─ register/
│  ├─ recovery/
│  ├─ dashboard/
│  │  ├─ page.tsx
│  │  └─ DashboardClient.tsx
│  ├─ api/
│  │  ├─ auth/
│  │  │  ├─ login/route.ts
│  │  │  ├─ logout/route.ts
│  │  │  ├─ extend/route.ts
│  │  │  ├─ session/route.ts
│  │  │  └─ register/route.ts
│  │  ├─ vault/
│  │  │  ├─ create/route.ts
│  │  │  ├─ list/route.ts
│  │  │  ├─ item/[id]/route.ts
│  │  │  ├─ delete/[id]/route.ts
│  │  │  └─ update/[id]/route.ts
│
├─ app/dashboard/components/
│  ├─ CreateModal.tsx
│  ├─ EditModal.tsx
│  ├─ ViewModal.tsx
│  ├─ SecurePasswordView.tsx
│  ├─ SessionTimer.tsx
│  └─ ThemeToggle.tsx
│
├─ lib/
│  ├─ db.ts
│  ├─ sessionStore.ts
│  ├─ crypto.ts
│  ├─ crypto-client.ts
│  └─ utils.ts
│
├─ db/
│  ├─ schema.sql
│  └─ seed.sql (선택)
│
└─ README.md
```

# 🧱 MySQL 설치 및 DB 준비
## 📥 1. MySQL 다운로드(MySQL이 이미 있으시다면 2번으로)

Windows 기준<br />
https://dev.mysql.com/downloads/installer/

설치 시 아래 옵션 선택:<br />
MySQL Server<br />
MySQL Workbench (선택)<br />
🔐설치시 설정한 root 비밀번호는 반드시 기억해주세요!🔐

## 🧰 2. MySQL 실행 후 데이터베이스 생성
MySQL 접속
```
mysql -uroot -p
#(설치시 설정한 root 비밀번호입력)
```
DB + User 생성:
```
#(pws_user와 pws_pass부분은 db사용자의 id와 pw로 임의로 변경가능)
CREATE DATABASE next_pws3 CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

CREATE USER 'pws_user'@'localhost' IDENTIFIED BY 'pws_pass';
GRANT ALL PRIVILEGES ON next_pws3.* TO 'pws_user'@'localhost';
FLUSH PRIVILEGES;
```

## 🧱 3. 테이블 스키마 적용

프로젝트 루트에서:
```
SOURCE db/schema.sql;
```
# 📘 schema.sql에 포함된 테이블 설명
## 📦 users 테이블
| 컬럼명                          | 타입       | 설명                       |
| ---------------------------- | -------- | ------------------------ |
| id                           | INT PK   | 사용자 ID                   |
| email                        | VARCHAR  | 사용자 이메일                  |
| username                     | VARCHAR  | 닉네임                      |
| password                     | VARCHAR  | bcrypt 해시된 로그인 비밀번호      |
| master_salt                  | VARCHAR  | PBKDF2 KDF용 salt |
| wrapped_data_key             | TEXT     | 서버 마스터키로 암호화된 dataKey    |
| wrapped_data_key_iv          | VARCHAR  | 해당 암호화에 사용된 IV (AES-GCM) |
| wrapped_data_key_recovery    | TEXT     | 복구키 기반 암호화된 dataKey      |
| wrapped_data_key_recovery_iv | VARCHAR  | 복구 IV                    |
| recovery_key_salt            | VARCHAR  | 복구키 KDF salt             |
| created_at                   | DATETIME | 생성일                      |

## 🔐 vault_items 테이블
| 컬럼명          | 타입       | 설명                         |
| ------------ | -------- | -------------------------- |
| id           | INT PK   | 항목ID                       |
| user_id      | INT      | 소유자 ID                     |
| site_name    | VARCHAR  | 사이트명                       |
| site_url     | VARCHAR  | URL                        |
| encrypted_pw | TEXT     | dataKey로 AES-GCM 암호화된 비밀번호 |
| iv           | VARCHAR  | 암호화에 사용된 IV                |
| created_at   | DATETIME | 생성일                        |
| updated_at   | DATETIME | 수정일                        |

## 🧪 sessions 테이블
| 컬럼명           | 타입       | 설명        |
| ------------- | -------- | --------- |
| session_id    | VARCHAR  | 세션 식별자    |
| user_id       | INT      | 유저 ID     |
| created_at    | DATETIME | 세션 생성 시각  |
| last_activity | DATETIME | 마지막 요청 시각 |

mysql에서 빠져나오기
```
exit
```

## 📄 환경 변수 설정 안내 (.env / .env.example)

프로젝트에는 실제 민감 정보가 포함된 .env 파일을 GitHub에 업로드하면 안 됩니다.
대신, 예시 템플릿 파일인 .env.example 이 포함되어 있어
사용자가 자신의 환경에 맞게 .env를 직접 생성할 수 있습니다.

아래 과정을 따라 .env 파일을 준비해 주세요.

### 📌 1) .env.example 파일을 .env로 복사
프로젝트를 클론한 후 루트 디렉토리에서 아래 명령을 실행합니다:
▶ Windows (PowerShell)
```
copy .env.example .env
```
▶ Windows (CMD)
```
copy .env.example .env
```
▶ macOS / Linux
```
cp .env.example .env
```

### 📌 2) .env 파일 내용 수정
복사된 .env 파일을 열고 pws_user, pws_pass 값을<br />
자신에게 맞는 값(이전에 설정한 pws_user, pws_pass부분)으로 교체합니다:
```
DB_HOST=localhost
DB_PORT=3306
DB_USER=pws_user
DB_PASSWORD=pws_pass
DB_NAME=next_pws3
```
## ⚠️ 주의:
.env는 절대 GitHub 등에 업로드하면 안 됩니다.
.env.example만 저장소에 포함되며, 예시 형식만 제공됩니다.

### 📌 3) 서버 재시작
.env 내용을 변경한 후에는 개발 서버를 반드시 재시작해야 적용됩니다.
```
npm run dev
```

## 📦 설치 & 실행
### 1. 패키지 설치
```
npm install
```

### 2. 개발 서버 실행
```
npm run dev
```
브라우저에서 실행:
```
http://localhost:3000
```
## 🔐 현재 보안 수준 요약
| 항목               | 상태       | 설명                          |
| ---------------- | -------- | --------------------------- |
| 비밀번호 저장 | 🔥 높은 수준 | AES-256-GCM + PBKDF2-HMAC-SHA256 KDF |
| 마스터 비밀번호 저장      | ❌ 저장 안 함 | 서버는 절대 사용자 마스터키를 모름         |
| 데이터키(dataKey) 보호 | 🔥 2중 보호 | 서버마스터키 + 사용자마스터키            |
| 복구 기능            | ✔️ 지원    | 복구키 있으면 계정 복구 가능            |
| 세션 보안            | 강화       | 서버 저장형, sliding renewal     |
| XSS 대응           | 보통       | React 자동 escaping           |
| CSRF 대응          | strong   | 인증은 HttpOnly Cookie + 세션 ID |

## 🏁 마무리
이 프로젝트는 학습용이지만,<br />
구조적으로는 실제 패스워드 매니저(LastPass · 1Password)와 유사한<br />
Zero-Knowledge 기반 암호화 설계를 따릅니다.