

resource "aws_cognito_user_pool" "slack_metrics" {
  //ユーザープール情報
  name                = "slack-metrics-${var.env}"
  user_pool_tier      = "ESSENTIALS"
  deletion_protection = "ACTIVE"
  admin_create_user_config {
    allow_admin_create_user_only = false
  }
  username_configuration {
    case_sensitive = false
  }
  //認証情報
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }
  password_policy {
    minimum_length                   = 8
    password_history_size            = 0
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }
  auto_verified_attributes = ["email"]
  username_attributes      = ["email"]

  //サインイン
  sign_in_policy {
    allowed_first_auth_factors = ["PASSWORD"]
  }
  mfa_configuration = "OFF"
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
    recovery_mechanism {
      name     = "verified_phone_number"
      priority = 2
    }
  }

  //サインアップ - パスワードポリシー
  schema {
    attribute_data_type      = "Number"
    developer_only_attribute = false
    mutable                  = true
    name                     = "userId"
    required                 = false
    number_attribute_constraints {
      max_value = null
      min_value = "1"
    }
  }
  schema {
    attribute_data_type      = "Number"
    developer_only_attribute = false
    mutable                  = true
    name                     = "workspaceId"
    required                 = false
    number_attribute_constraints {
      max_value = null
      min_value = "1"
    }
  }
  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true
    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }

  //メッセージテンプレート
  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }
}



resource "aws_cognito_user_pool_client" "slack_metrics" {
  name         = "slack-metrics-${var.env}"
  user_pool_id = aws_cognito_user_pool.slack_metrics.id
  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]
  auth_session_validity  = 3
    token_validity_units {
    access_token = "minutes"
    id_token = "minutes"
    refresh_token = "days"
  }
  id_token_validity      = 60
  access_token_validity  = 60
  refresh_token_validity = 5
  enable_token_revocation                       = true
  enable_propagate_additional_user_context_data = false
  allowed_oauth_flows_user_pool_client          = true
  prevent_user_existence_errors                 = "ENABLED"

  //属性権限
  read_attributes                               = ["custom:userId", "custom:workspaceId", "email"]
  write_attributes                              = ["custom:userId", "custom:workspaceId", "email"]

//ログインページ
  callback_urls                                 = ["https://d84l1y8p4kdic.cloudfront.net"]
  supported_identity_providers                  = ["COGNITO"]
  allowed_oauth_flows                           = ["code"]
  allowed_oauth_scopes                          = ["openid"]
  logout_urls = []
}
