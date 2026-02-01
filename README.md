## バージョン管理について

バージョン管理は tenv を使用しています。
構築手順については以下を参照
- [Terraformのバージョン管理 tenv](https://kirara.cloud-pratica.com/cloud-pratica/tasks/371)

## ディレクトリ構造について

```
.
├── README.md
├── modules // モジュール
│   └── gcp
│   └── aws
│       ├── ecr
│       ├── iam_role
│       ├── lambda
│       ├── parameter_store
│       ├── s3
│       ├── secrets_manager
│       ├── security_group
│       └── target_group
│   └── aggregation
│       └── datadog
│           └── aws
├── prd
│   └── variables.tf // ローカル変数やシークレット変数を定義
│   └── backend.tf // tfstateファイルの保存先を設定
│   └── versions.tf // Terraformのバージョンやプロバイダーのバージョンを設定
│   └── aws.tf // AWSリソースを定義
│   └── .envrc // ローカル環境用のenvファイル
└── stg
    ├── aws.tf
    ├── backend.tf
    ├── variables.tf
    └── versions.tf
    └── .envrc
```
