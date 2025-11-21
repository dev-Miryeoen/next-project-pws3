# 🔐 next-project-pws3
Local Password Manager — Next.js + MySQL 기반 안전한 비밀번호 관리 서비스

# 📌 프로젝트 소개
next-project-pws3는 Next.js와 MySQL 기반으로 제작된
완전한 로컬 비밀번호 관리 프로그램(Local Password Manager) 입니다.

이 프로젝트는 웹사이트 비밀번호를 안전하게 저장하고,
사용자가 입력한 마스터 비밀번호 기반 AES-256 암호화 구조로
절대 평문 비밀번호가 서버에 저장되지 않도록 설계되었습니다.

# 🔥 핵심 특징
## ✔️ 1. 2중 보안 암호화 구조
### 🔑 1) 서버 마스터 키(Server Master Key)
랜덤 256bit AES key
서버 관리자도 평문을 모름
DB에는 다음 3개만 저장됨:
wrapped_data_key (AES-GCM으로 암호화된 dataKey)
wrapped_data_key_iv
master_salt (Argon2 KDF용)

### 🔒 2) 사용자 마스터 키(User Master Password)
Argon2id KDF를 통해 dataKey 복구
dataKey로 개별 비밀번호 AES-GCM 암호화
마스터 비밀번호는 절대 서버에 저장되지 않음

### 🔁 복구키(Recovery Key)
사용자가 초기 가입 시 랜덤으로 생성됨
서버 마스터 키로 암호화된 형태로 저장
사용자 마스터 비밀번호를 잃어버려도 복구키만 있으면 복구 가능

## ✔️ 2. 보안 강화된 세션 시스템
MySQL 기반 세션 저장소
서버가 세션 유효시간을 직접 판단
클라이언트는 1초 단위 UI 타이머 / 10초 단위 서버 동기화
세션 만료 시 즉시 강제 로그아웃
“연장하기” 버튼으로 5분 연장 가능

## ✔️ 3. 기능 구성
회원가입 / 로그인 / 로그아웃
마스터키 + 복구키 기반 보안 시스템
비밀번호 생성, 수정, 삭제 (CRUD)
마스터 비밀번호 입력 시 복호화 기능
비밀번호 보기 시 10초 자동 삭제 표시(SecurePasswordView)
Dark Mode 지원
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

Windows 기준
https://dev.mysql.com/downloads/installer/

설치 시 아래 옵션 선택:

MySQL Server

MySQL Workbench (선택)

## 🧰 2. MySQL 실행 후 데이터베이스 생성
MySQL 접속
```
mysql -u root -p
```
DB + User 생성
```
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
| master_salt                  | VARCHAR  | Argon2 KDF용 salt         |
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

## ⚙️ 환경 변수 설정 (.env)
루트 위치에 .env 파일 생성:
```
DB_HOST=localhost
DB_USER=pws_user
DB_PASSWORD=pws_pass
DB_DATABASE=next_pws3

# 서버 마스터 키 (절대로 외부유출 금지)
SERVER_MASTER_KEY=HEX_32_BYTES

# 세션 지속시간 설정 (ms)
SESSION_DURATION=300000
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
| 비밀번호 저장          | 🔥 최고 수준 | AES-256-GCM + Argon2id KDF  |
| 마스터 비밀번호 저장      | ❌ 저장 안 함 | 서버는 절대 사용자 마스터키를 모름         |
| 데이터키(dataKey) 보호 | 🔥 2중 보호 | 서버마스터키 + 사용자마스터키            |
| 복구 기능            | ✔️ 지원    | 복구키 있으면 계정 복구 가능            |
| 세션 보안            | 강화       | 서버 저장형, sliding renewal     |
| XSS 대응           | 보통       | React 자동 escaping           |
| CSRF 대응          | strong   | 인증은 HttpOnly Cookie + 세션 ID |

## 🏁 마무리

이 프로젝트는 학습용이지만,
구조적으로는 실제 패스워드 매니저(LastPass · 1Password)와 유사한
Zero-Knowledge 기반 암호화 설계를 따릅니다.