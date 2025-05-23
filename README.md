# アプリ名
### Rihlar
世界一歩いた人の旅行記の名前がThe Rihla + lar がアラビア語で複数形

## 開発環境/言語
- **フロントエンド**
    swift
- **バックエンド**
    
  
## 機能概要(機能一覧)
- **位置情報・歩数連携 機能**  
    
- **陣取り 機能**  
    
- **写真連携 機能**  
    
- **ガチャ 機能**  
    

### 1. テーブル
テーブルの説明

| カラム名         | データ型          | NULL許可 | キー        | デフォルト値           | 説明               |
|------------------|-------------------|----------|-------------|------------------------|--------------------|
| id               | INT               | NO       | PRIMARY KEY | AUTO_INCREMENT         | ユーザーID          |
| username         | VARCHAR(50)       | YES      |             |                        | ユーザー名          |
| email            | VARCHAR(100)      | NO       | UNIQUE      |                        | メールアドレス      |
| password         | VARCHAR(255)      | NO       |             |                        | パスワード          |
| postal_code      | VARCHAR(10)       | NO       |             |                        | 郵便番号            |
| date_of_birth    | DATE              | YES      |             |                        | 生年月日            |
| gender           | ENUM('男', '女', 'その他') | YES |           |                        | 性別               |
| favorite_recipe  | JSON              | YES      |             |                        | 好きなレシピ情報    |
| profile_image    | BLOB              | YES      |             |                        | プロフィール画像    |
| created_at       | TIMESTAMP         | NO       |             | CURRENT_TIMESTAMP      | アカウント作成日時  |


## コンセプト

## こだわったポイント

## コーディング面でこだわったポイント

## デザイン面でこだわったポイント



test
