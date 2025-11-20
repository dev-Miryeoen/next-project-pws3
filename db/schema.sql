-- 🔐 next-project-pws3 : Password Simple Storage Service
-- DB 스키마 파일

-- DB 생성
CREATE DATABASE IF NOT EXISTS next_pws3 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE next_pws3;

-- 사용자 테이블
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL, -- 해시된 비밀번호
    email VARCHAR(255) NOT NULL UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 비밀번호 보관소(vault) 테이블
CREATE TABLE IF NOT EXISTS vault_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    site_name VARCHAR(255) NOT NULL,      -- 비밀번호 사용처 명
    site_url VARCHAR(500),                -- 해당 URL
    encrypted_pw TEXT NOT NULL,           -- AES 암호화된 비밀번호
    iv VARCHAR(255) NOT NULL,             -- 암호화용 IV
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
