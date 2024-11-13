provider "aws" {
  region = "ap-south-1"
}

resource "aws_dynamodb_table" "feedback_table" {
  name           = "FeedbackTable"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

terraform {
  backend "s3" {
    bucket         = "serverless-framework-deployments-ap-south-1-3264d127-bbb4"
    key            = "tfstate/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_lambda_function" "feedback_function" {
  function_name = "FeedbackFunction"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_role.arn
  handler       = "handler.handler"

  filename         = "../functions/handler.zip"
  source_code_hash = filebase64sha256("../functions/handler.py")

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.feedback_table.name
    }
  }
}
